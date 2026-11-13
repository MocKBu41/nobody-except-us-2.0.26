/* NEU portrait uploader: a separate per-card control, publishing through the GitHub Contents API.
   No credentials are bundled or written to browser storage. */
(function(){
  'use strict';

  const REPO = 'MocKBu41/nobody-except-us-2.0.26';
  const BRANCH = 'main';
  const ROOT = 'NEU-Portraits/';
  const API = 'https://api.github.com/repos/' + REPO;
  const TARGET_WIDTH = 816;
  const TARGET_HEIGHT = 548;
  const MAX_FILE_BYTES = 12 * 1024 * 1024;
  let sessionToken = '';

  function node(tag, className, content) {
    const el = document.createElement(tag);
    if (className) el.className = className;
    if (content !== undefined) el.textContent = content;
    return el;
  }

  function githubPath(path) {
    return path.split('/').map(encodeURIComponent).join('/');
  }

  async function request(path, token, method, body) {
    const response = await fetch(API + path, {
      method: method || 'GET',
      headers: {
        'Accept': 'application/vnd.github+json',
        'Authorization': 'Bearer ' + token,
        'X-GitHub-Api-Version': '2022-11-28',
        ...(body === undefined ? {} : {'Content-Type': 'application/json'})
      },
      ...(body === undefined ? {} : {body: JSON.stringify(body)}),
      cache: 'no-store'
    });
    let result;
    try { result = await response.json(); } catch (_) { result = {}; }
    if (!response.ok) {
      const error = new Error('GitHub ' + response.status + ': ' +
        (result.message || 'не удалось выполнить запрос'));
      error.status = response.status;
      throw error;
    }
    return result;
  }

  async function contentOrNull(path, token) {
    try {
      return await request('/contents/' + githubPath(path) + '?ref=' + BRANCH, token);
    } catch (error) {
      if (error.status === 404) return null;
      throw error;
    }
  }

  function decodeBase64Utf8(base64) {
    const binary = atob(base64.replace(/\s/g, ''));
    const bytes = Uint8Array.from(binary, character => character.charCodeAt(0));
    return new TextDecoder().decode(bytes);
  }

  function encodeBase64Utf8(text) {
    const bytes = new TextEncoder().encode(text);
    let binary = '';
    for (let i = 0; i < bytes.length; i += 8192) {
      binary += String.fromCharCode.apply(null, bytes.subarray(i, i + 8192));
    }
    return btoa(binary);
  }

  async function fileBase64(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => resolve(String(reader.result).split(',')[1]);
      reader.onerror = () => reject(new Error('Не удалось прочитать PNG.'));
      reader.readAsDataURL(file);
    });
  }

  async function toPortraitPng(file) {
    if (!/^image\/(png|jpeg|webp)$/i.test(file.type)) {
      throw new Error('Выберите изображение PNG, JPG или WebP.');
    }
    if (!file.size || file.size > MAX_FILE_BYTES) {
      throw new Error('Размер исходного файла должен быть не больше 12 МБ.');
    }

    const objectUrl = URL.createObjectURL(file);
    const image = new Image();
    try {
      await new Promise((resolve, reject) => {
        image.onload = resolve;
        image.onerror = () => reject(new Error('Файл изображения не читается.'));
        image.src = objectUrl;
      });
      if (!image.naturalWidth || !image.naturalHeight) {
        throw new Error('Изображение имеет некорректные размеры.');
      }

      const canvas = document.createElement('canvas');
      canvas.width = TARGET_WIDTH;
      canvas.height = TARGET_HEIGHT;
      const ctx = canvas.getContext('2d', {alpha: false});
      if (!ctx) throw new Error('Не удалось обработать изображение.');
      // Preserve proportions; fill any unused margins, never stretch or crop the portrait.
      ctx.fillStyle = '#17252c';
      ctx.fillRect(0, 0, TARGET_WIDTH, TARGET_HEIGHT);
      const scale = Math.min(TARGET_WIDTH / image.naturalWidth, TARGET_HEIGHT / image.naturalHeight);
      const w = image.naturalWidth * scale;
      const h = image.naturalHeight * scale;
      ctx.imageSmoothingEnabled = true;
      ctx.imageSmoothingQuality = 'high';
      ctx.drawImage(image, (TARGET_WIDTH - w) / 2, (TARGET_HEIGHT - h) / 2, w, h);
      return await new Promise((resolve, reject) => {
        canvas.toBlob(blob => blob ? resolve(blob) :
          reject(new Error('Не удалось создать PNG.')), 'image/png');
      });
    } finally {
      URL.revokeObjectURL(objectUrl);
    }
  }

  function portraitFilename(unit) {
    if (unit.image && /\.png$/i.test(unit.image)) return unit.image;
    const clean = unit.name.replace(/[^\p{L}\p{N}]+/gu, '_').replace(/^_|_$/g, '');
    return unit.id + '_' + clean + '.png';
  }

  function attachPortraitUpload(unit, card, thumb) {
    const slot = node('div', 'portrait-upload');
    const choose = node('button', 'upload-choose', 'Загрузить изображение');
    choose.type = 'button';
    choose.setAttribute('aria-label', 'Загрузить изображение для #' + unit.id + ' — ' + unit.name);
    const picker = node('input');
    picker.type = 'file';
    picker.accept = 'image/png,image/jpeg,image/webp';
    picker.hidden = true;
    picker.setAttribute('aria-label', 'Файл изображения для #' + unit.id);

    const details = node('div', 'upload-details');
    details.hidden = true;
    const preview = node('img', 'upload-preview');
    preview.alt = 'Выбранное изображение для #' + unit.id;
    const hint = node('p', 'upload-hint',
      'PNG, JPG, WebP. Перед публикацией изображение преобразуется в PNG 816×548 без обрезки.');
    const tokenLabel = node('label', 'upload-hint',
      'GitHub fine-grained token (Contents: Read and write), только для этого репозитория:');
    const tokenInput = node('input', 'upload-token');
    tokenInput.type = 'password';
    tokenInput.autocomplete = 'off';
    tokenInput.spellcheck = false;
    tokenInput.placeholder = 'github_pat_…';
    tokenInput.setAttribute('aria-label', 'Токен GitHub для публикации');
    const tokenHelp = node('a', 'upload-help', 'Создать токен GitHub ↗');
    tokenHelp.href = 'https://github.com/settings/personal-access-tokens/new';
    tokenHelp.target = '_blank';
    tokenHelp.rel = 'noopener noreferrer';
    const help = node('p', 'upload-hint',
      'Токен не отправляется на этот сайт и не сохраняется в localStorage. Он используется только при запросах к api.github.com и остаётся в памяти вкладки.');
    const buttons = node('div', 'upload-buttons');
    const publish = node('button', 'upload-publish', 'Опубликовать на GitHub');
    publish.type = 'button';
    const cancel = node('button', 'upload-cancel', 'Отмена');
    cancel.type = 'button';
    const status = node('div', 'upload-status');
    status.setAttribute('role', 'status');
    status.setAttribute('aria-live', 'polite');
    buttons.append(publish, cancel);
    details.append(preview, hint, tokenLabel, tokenInput, tokenHelp, help, buttons, status);
    slot.append(choose, picker, details);
    card.append(slot);

    let selectedFile = null;
    let previewUrl = '';
    let busy = false;

    function reset() {
      if (busy) return;
      details.hidden = true;
      picker.value = '';
      selectedFile = null;
      tokenInput.value = '';
      status.replaceChildren();
      if (previewUrl) {
        URL.revokeObjectURL(previewUrl);
        previewUrl = '';
      }
    }

    choose.addEventListener('click', () => { if (!busy) picker.click(); });
    cancel.addEventListener('click', reset);
    picker.addEventListener('change', () => {
      const file = picker.files && picker.files[0];
      if (!file) return;
      if (!/^image\/(png|jpeg|webp)$/i.test(file.type) || !file.size || file.size > MAX_FILE_BYTES) {
        details.hidden = false;
        status.textContent = 'Допускается PNG, JPG или WebP размером до 12 МБ.';
        selectedFile = null;
        publish.disabled = true;
        return;
      }
      if (previewUrl) URL.revokeObjectURL(previewUrl);
      previewUrl = URL.createObjectURL(file);
      preview.src = previewUrl;
      selectedFile = file;
      publish.disabled = false;
      details.hidden = false;
      status.textContent = 'Файл «' + file.name + '» выбран для отряда #' + unit.id + '.';
      tokenLabel.hidden = Boolean(sessionToken);
      tokenInput.hidden = Boolean(sessionToken);
      tokenHelp.hidden = Boolean(sessionToken);
      help.hidden = Boolean(sessionToken);
    });

    publish.addEventListener('click', async () => {
      if (!selectedFile || busy) return;
      const token = sessionToken || tokenInput.value.trim();
      if (!token) {
        status.textContent = 'Для публикации укажите GitHub fine-grained token с правом Contents: Read and write.';
        tokenInput.focus();
        return;
      }
      busy = true;
      publish.disabled = true;
      choose.disabled = true;
      cancel.disabled = true;
      let imageCommitted = false;
      try {
        status.textContent = 'Подготовка PNG 816×548…';
        const blob = await toPortraitPng(selectedFile);
        const base64 = await fileBase64(blob);
        const filename = portraitFilename(unit);
        const path = ROOT + 'images/' + filename;
        status.textContent = 'Загрузка изображения в GitHub…';
        const existing = await contentOrNull(path, token);
        const result = await request('/contents/' + githubPath(path), token, 'PUT', {
          message: 'NEU-Portraits: upload image for #' + unit.id,
          content: base64,
          branch: BRANCH,
          ...(existing && existing.sha ? {sha: existing.sha} : {})
        });
        imageCommitted = true;
        const imageSha = result.content && result.content.sha;
        if (!imageSha) throw new Error('GitHub не вернул SHA загруженного PNG.');

        status.textContent = 'PNG загружен. Обновление manifest.json…';
        const manifestFile = await contentOrNull(ROOT + 'manifest.json', token);
        if (!manifestFile || !manifestFile.sha || !manifestFile.content) {
          throw new Error('Не удалось получить manifest.json из репозитория.');
        }
        const manifest = JSON.parse(decodeBase64Utf8(manifestFile.content));
        if (!Array.isArray(manifest.units)) throw new Error('Неверный формат manifest.json.');
        const entry = manifest.units.find(row => String(row.id) === String(unit.id));
        if (!entry) throw new Error('ID #' + unit.id + ' отсутствует в manifest.json.');
        entry.hasImage = true;
        entry.image = filename;
        entry.imageVersion = imageSha;
        entry.reviewStatus = 'Черновик — требует проверки';
        manifest.published_count = manifest.units.filter(row => Boolean(row.image)).length;
        manifest.total_count = manifest.units.length;
        manifest.revision = 'upload-' + Date.now() + '-' + unit.id;
        const manifestUpdate = await request('/contents/' + githubPath(ROOT + 'manifest.json'),
          token, 'PUT', {
            message: 'NEU-Portraits: register image for #' + unit.id,
            content: encodeBase64Utf8(JSON.stringify(manifest, null, 2) + '\n'),
            branch: BRANCH,
            sha: manifestFile.sha
          });

        sessionToken = token;
        tokenInput.value = '';
        unit.image = filename;
        unit.hasImage = true;
        unit.imageVersion = imageSha;
        if (typeof saved !== 'undefined' && saved[unit.id]) {
          saved[unit.id] = {...saved[unit.id], status: 'draft'};
          if (typeof store === 'function') store();
        }
        if (typeof updateMetrics === 'function') updateMetrics();

        // Keep a visible local preview until the GitHub Pages deployment catches up.
        const placeholder = thumb.querySelector('.placeholder');
        if (placeholder) placeholder.remove();
        let displayedImage = thumb.querySelector('img');
        if (!displayedImage) {
          displayedImage = new Image();
          displayedImage.alt = 'Портрет ' + unit.name;
          thumb.prepend(displayedImage);
          thumb.addEventListener('click', () => {
            document.getElementById('viewerTitle').textContent = unit.id + ' · ' + unit.name;
            document.getElementById('viewerImg').src = displayedImage.src;
            document.getElementById('viewer').showModal();
          });
        }
        // New object URL must survive the preview panel being closed.
        displayedImage.src = URL.createObjectURL(blob);
        thumb.classList.add('available');
        const badge = thumb.querySelector('.tag');
        if (badge) badge.textContent = 'ЧЕРНОВИК · PNG';
        const links = card.querySelector('.links');
        if (links && !links.querySelector('a')) {
          links.replaceChildren();
          const link = node('a', '', 'PNG на GitHub ↗');
          link.href = 'https://github.com/' + REPO + '/blob/' + BRANCH + '/' +
            ROOT + 'images/' + encodeURIComponent(filename);
          link.target = '_blank';
          link.rel = 'noopener noreferrer';
          links.append(link);
        }
        if (typeof apply === 'function') apply();
        status.replaceChildren(document.createTextNode(
          'Изображение опубликовано в GitHub. Сайт обновится после развёртывания GitHub Pages. '
        ));
        const commit = node('a', '', 'Открыть коммит ↗');
        commit.href = 'https://github.com/' + REPO + '/commit/' + manifestUpdate.commit.sha;
        commit.target = '_blank';
        commit.rel = 'noopener noreferrer';
        status.append(commit);
        status.classList.add('upload-success');
        tokenLabel.hidden = tokenInput.hidden = tokenHelp.hidden = help.hidden = true;
      } catch (error) {
        status.classList.remove('upload-success');
        status.textContent = (imageCommitted
          ? 'PNG уже загружен в GitHub, но каталог не обновился. Повторите публикацию. '
          : 'Публикация не выполнена. ') + error.message;
      } finally {
        busy = false;
        publish.disabled = false;
        choose.disabled = false;
        cancel.disabled = false;
      }
    });
  }

  window.attachPortraitUpload = attachPortraitUpload;
})();

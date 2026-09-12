(define "vision_new_optic_human_cannon_ground"
        ("human_in_IR_and_optic_spectre_ground" optic(1) human_ir(1) firing_ir(1))
        ("cannon_in_IR_and_optic_spectre_ground" optic(1) human_ir(1) firing_ir(1))

)
(define "vision_new_optic_vehicle_ground"
        ("ground_veh_in_IR_and_optic_spectre_ground" optic(1) moving_ir(1) firing_ir(1))
        ("aviation_in_IR_and_optic_spectre" optic(1) moving_ir(1) firing_ir(1))
        ("marine_in_IR_and_optic_spectre" optic(1))
        ("missile_visible")
        ("proj_point_invisible")
)
(define "vision_new_optic_IR_human_cannon_ground"
        ("human_in_IR_and_optic_spectre_ground" optic(1) human_ir(1.15) firing_ir(1.20))
        ("cannon_in_IR_and_optic_spectre_ground" optic(1) human_ir(1.15) firing_ir(1.20))

)
(define "vision_new_optic_IR_vehicle_ground"
        ("ground_veh_in_IR_and_optic_spectre_ground" optic(1) moving_ir(1.15) firing_ir(1.15))
        ("aviation_in_IR_and_optic_spectre" optic(1) moving_ir(1.20) firing_ir(1.20))
        ("marine_in_IR_and_optic_spectre" optic(1))
        ("missile_visible")
        ("proj_point_invisible")
)

;ground

(define "vision_optic_modern_1gen_ground"
    ("radius" r(79))        
    {rules   
    ("vision_new_optic_human_cannon_ground")
    ("vision_new_optic_vehicle_ground")
    }
    {mods {stand 1}}
)

(define "vision_optic_modern_2gen_ground"
    ("radius" r(95))        
    {rules   
    ("vision_new_optic_human_cannon_ground")
    ("vision_new_optic_vehicle_ground")
    }
    {mods
        {stand 1}
    }
)
(define "vision_optic_modern_3gen_ground"
    ("radius" r(105))       
    {rules   
    ("vision_new_optic_human_cannon_ground")
    ("vision_new_optic_vehicle_ground")
    }
    {mods
        {stand 1}
    }
)
(define "vision_optic_modern_4gen_ground"
    ("radius" r(115))       
    {rules   
    ("vision_new_optic_human_cannon_ground")
    ("vision_new_optic_vehicl_grounde")
    }
    {mods
        {stand 1}
    }
)

(define "vision_optic_modern_and_IR_1gen_ground"
    ("radius" r(79))        
    {rules   
    ("vision_new_optic_IR_human_cannon_ground")
    ("vision_new_optic_IR_vehicle_ground")
    }
    {mods
        {stand 1}
    }
)
(define "vision_optic_modern_and_IR_2gen_ground"
    ("radius" r(95))        
    {rules   
    ("vision_new_optic_IR_human_cannon_ground")
    ("vision_new_optic_IR_vehicle_ground")
    }
    {mods
        {stand 1}
    }
)
(define "vision_optic_modern_and_IR_3gen_ground"
    ("radius" r(105))       
    {rules   
    ("vision_new_optic_IR_human_cannon_ground")
    ("vision_new_optic_IR_vehicle_ground")
    }
    {mods
        {stand 1}
    }
)
(define "vision_optic_modern_and_IR_4gen_ground"
    ("radius" r(115))       
    {rules   
    ("vision_new_optic_IR_human_cannon_ground")
    ("vision_new_optic_IR_vehicle_ground")
    }
    {mods
        {stand 1}
    }
)
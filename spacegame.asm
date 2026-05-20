
ORG 0x9000
MOV sp,0x7c00
JMP startsp


;bx=ffff
;dx=ffff


;NEED AL

debug_hex:
          CALL shex
          MOV ah,0xe
          MOV al,0x30
          INT 10h
          MOV al,'x'
          INT 10h
          MOV al,[hex]
          INT 10h
          MOV al,[hex+1]
          INT 10h
          RET

shex:
     PUSH ax
     PUSH cx
     XOR cx,cx
     XOR ah,ah
     MOV cl,al
     SHR al,4
     MOV ah,al
     XOR al,al
     AND cl,0xf
     MOV al,cl
     CMP ah,0x0a
     JGE pah
     ADD ah,0x30
     JMP contc

contc:
      CMP al,0x0a
      JGE pal
      ADD al,0x30
      JMP endl

pah:
    ADD ah,0x57
    JMP contc

pal:
    ADD al,0x57
    JMP endl

endl:
     MOV [hex],ah
     MOV [hex+1],al
     POP cx
     POP ax
     RET





animation_timer:
                NOP
                CMP WORD [bx_time],0x0000
                JZ nested_loop
                DEC WORD [bx_time]
                JMP loopx

nested_loop:
            CMP WORD [dx_time],0x0000
            JZ end_nested_loop
            DEC WORD [dx_time]
            
            PUSH bx
            MOV bx,[bx_time_bak]
            MOV [bx_time],bx
            POP bx
            
            JMP loopx
loopx:
      RET

end_nested_loop:
                DEC BYTE [chick_down_count]
                CALL cls_chick_draw_all
                CALL chick_down
                CALL change_chicken_state
                CALL chick_draw_all       
                PUSH bx
                MOV bx,[bx_time_bak]
                MOV [bx_time],bx
                MOV bx,[dx_time_bak]
                MOV [dx_time],bx
                POP bx
                 
                JMP loopx
                
;chick_many DB 5,13,18,13,31,13,44,13,57,13,0xff

chick_down:
           CMP BYTE [chick_down_count],0
           JNZ end_chick_down
           
           CMP BYTE [chick_many+1],0x14
           JGE end_chick_down
           
           PUSHA
           MOV si,chick_many
           JMP chdn
           
chdn:
     INC BYTE [si+1]
     JMP next_chdn
     
next_chdn:
          INC si
          INC si
          CMP BYTE [si],0xff
          JE chdn_end
          JMP chdn
     
chdn_end:     
        MOV BYTE [chick_down_count],8
        POPA
        
        CMP BYTE [total_chickmany],0
        JNZ end_chick_down
        JMP chick_bak
       
           
end_chick_down:
               RET

;0x14



chick_bak:
          PUSH si
          PUSH bx
          PUSH ax
          MOV si,chick_many
          MOV bx,chick_many_bak
          MOV al,[bx+1]
          JMP chk_bak
           
chk_bak:
        MOV ah,[bx]
        MOV [si],ah
        MOV [si+1],al
        INC si
        INC si
        INC bx
        INC bx
        CMP BYTE [bx],0xff
        JE chk_bak_end
        JMP chk_bak
     
chk_bak_end:     
            POP ax
            POP bx
            POP si
            MOV BYTE [total_chickmany],5
            RET
          






;dh r dl coln
;ax,bx,dx
;ah 2h 10h

set_cursor:
           PUSHA
           XOR dx,dx
           MOV ah,2h
           MOV bh,0
           MOV dl,ch
           MOV dh,cl
           INT 10h
           POPA
           RET



init_drawer:
            MOV dx,ax
            MOV cx,ax
            CALL set_cursor
            RET


pt_ascii:
         PUSH ax
         PUSH bx
         PUSH cx
         PUSH dx
         MOV ah,0xe
         MOV al,[si]
         INT 10h
         INC si
         CMP BYTE [si],'$'
         JE end_now               
         POP dx
         POP cx
         POP bx
         POP ax
         RET



xy_ascii_loop:
              MOV cx,dx
              ADD ch,[bx]
              ADD cl,[bx+1]
              CALL set_cursor
              CALL pt_ascii
              INC bx
              INC bx
              JMP xy_ascii_loop


end_now:
         POP dx
         POP cx
         POP bx
         POP ax
         POP si    ;just using si to make sp skip  one ret address that is the address of " CALL pt_ascii"
         XOR si,si
         RET



unknown1:
         JMP WORD [unknown1_db]

unknown2:
         JMP WORD [unknown2_db]

unknown3:
         JMP WORD [unknown3_db]

unknown4:
         JMP WORD [unknown4_db]



init_temp:
          NOP
          RET


tmp_shipbody:
             MOV si,shipbody
             RET

tmp_cls_shipbody:
                 MOV si,cls_shipbody
                 RET
                 
tmp_flames_star:
                MOV si,flames_star
                RET
tmp_flames_plus:
                MOV si,flames_plus
                RET
tmp_flames_clear:
                 MOV si,flames_clear
                 RET               

tmp_shasm:
          MOV bx,shasm
          RET
          
          
tmp_flames_relative_xy:
                       MOV bx,flames_relative_xy
                       RET


tmp_chick1:
           MOV si,chick1
           RET

tmp_chick1_xy:
              MOV bx,chick1_xy
              RET


tmp_chick1cls:
              MOV si,chick1cls
              RET


tmp_bullet:
           MOV si,bullet
           RET

tmp_cls_bullet:
                MOV si,cls_bullet
                RET

tmp_bullet_relative:
                    MOV bx,bullet_relative
                    RET

tmp_bullet_trogectry:
                     MOV si,bullet_trogectry
                     RET
        
       
                     
tmp_egg_trojectory:
                    MOV si,egg_trojectory
                    RET
                    
                     



drawer:
       CALL init_drawer
       CALL unknown1
       CALL pt_ascii
       CALL unknown2
       JMP xy_ascii_loop


shipdrawer:
           MOV WORD [unknown1_db],tmp_shipbody
           MOV WORD [unknown2_db],tmp_shasm
           MOV ah,[shipbody_xy]
           MOV al,[shipbody_xy+1]
           JMP drawer

cls_shipdrawer:
               MOV WORD [unknown1_db],tmp_cls_shipbody
               MOV WORD [unknown2_db],tmp_shasm
               MOV ah,[shipbody_xy]
               MOV al,[shipbody_xy+1]
               JMP drawer
               
flames_star_drawer:
                   MOV WORD [unknown1_db],tmp_flames_star
                   MOV WORD [unknown2_db],tmp_flames_relative_xy
                   MOV ah,[shipbody_xy]
                   MOV al,[shipbody_xy+1]
                   ADD ah,-1
                   ADD al,3
                   JMP drawer

flames_plus_drawer: 
                   MOV WORD [unknown1_db],tmp_flames_plus
                   MOV WORD [unknown2_db],tmp_flames_relative_xy
                   MOV ah,[shipbody_xy]
                   MOV al,[shipbody_xy+1]
                   ADD ah,-1
                   ADD al,3
                   JMP drawer  
           
flames_clear_drawer:
                    MOV WORD [unknown1_db],tmp_flames_clear
                    MOV WORD [unknown2_db],tmp_flames_relative_xy
                    MOV ah,[shipbody_xy]
                    MOV al,[shipbody_xy+1]
                    ADD ah,-1
                    ADD al,3
                    JMP drawer  


chick1drawer:
             MOV WORD [unknown1_db],tmp_chick1
             MOV WORD [unknown2_db],tmp_chick1_xy
             JMP drawer

chick1clear:
            MOV WORD [unknown1_db],tmp_chick1cls
            MOV WORD [unknown2_db],tmp_chick1_xy
            JMP drawer



chick_draw_all:
                MOV WORD [unknown3_db],chick1drawer
                JMP draw_all

cls_chick_draw_all:
                   MOV WORD [unknown3_db],chick1clear
                   JMP draw_all

bullet_drawer:
              MOV WORD [unknown1_db],tmp_bullet
              MOV WORD [unknown2_db],tmp_bullet_relative
              ;MOV ah,[shipbody_xy]
              ;MOV al,[shipbody_xy+1]
              JMP drawer

cls_bullet_drawer:
                  MOV WORD [unknown1_db],tmp_cls_bullet
                  MOV WORD [unknown2_db],tmp_bullet_relative
                ;MOV ah,[shipbody_xy]
                ;MOV al,[shipbody_xy+1]
                  JMP drawer


bullet_trogectry_drawer:
                        CMP WORD [bx_time],0x031e
                        JNE end_bullet_trogectry_drawer
                        MOV WORD [unknown4_db],tmp_bullet_trogectry
                        MOV WORD [unknown3_db],bullet_drawer
                        MOV BYTE [render_choice],'r'
                        JMP render_weapons
end_bullet_trogectry_drawer:
                            RET


cls_bullet_trogectry_drawer:
                            CMP WORD [bx_time],0x001e
                            JNE end_cls_bullet_trogectry_drawer
                            MOV WORD [unknown4_db],tmp_bullet_trogectry
                            MOV WORD [unknown3_db],cls_bullet_drawer
                            MOV BYTE [render_choice],'b'
                            JMP render_weapons
end_cls_bullet_trogectry_drawer:
                                RET


egg_drawer:
           PUSHA
           CALL init_drawer
           MOV ah,0xe
           MOV al,[egg]
           INT 10h
           POPA
           RET
           
cls_egg_drawer:
                PUSHA
                CALL init_drawer
                MOV ah,0xe
                MOV al,0x20
                INT 10h
                POPA
                RET

         


egg_trojectory_drawer:
                        CMP WORD [dx_time],0x0015
                        JNE end_egg_trojectory_drawer
                        CMP WORD [bx_time],0x0001
                        JNE end_egg_trojectory_drawer
                        MOV WORD [unknown4_db],tmp_egg_trojectory
                        MOV WORD [unknown3_db],egg_drawer
                        MOV BYTE [render_choice],'r'
                        JMP render_weapons
                        
end_egg_trojectory_drawer:
                          RET

cls_egg_trojectory_drawer:
                          CMP WORD [dx_time],0x0009
                          JNE cls_end_egg_trojectory_drawer
                          CMP WORD [bx_time],0x0001
                          JNE cls_end_egg_trojectory_drawer
                          MOV WORD [unknown4_db],tmp_egg_trojectory
                          MOV WORD [unknown3_db],cls_egg_drawer
                          MOV BYTE [render_choice],'e'
                          JMP render_weapons
                        
cls_end_egg_trojectory_drawer:
                              RET



cmp_and:
       PUSHA
       MOV al,[constant_cmp1]  ;si+1   bullet
       MOV bl,[constant_cmp2] ;si
       MOV cl,[var1]  ;bx+1            chicken
       MOV dl,[var2] ;bx
       
       MOV ch,dl
       ADD ch,8
       
       
       CMP al,cl
       sete ah

       CMP bl,dl
       setge bh      
       CMP bl,ch
       setle dh
       AND bh,dh
       
       ;AND ah,bh
       ;MOV [output_logic],ah
       AND bh,ah
       MOV [output_logic],bh
       
       ; bullet_relative DB 1,0,-6,2,7,2
        
        
       ADD bl,1
       ;CMP al,cl
       ;sete ah
       
       CMP bl,dl
       setge bh
       CMP bl,ch
       setle dh
       AND bh,dh
       
       AND ah,bh
       OR [output_logic],ah
 
 
       ADD bl,-7
       ADD al,2
      
       
       CMP al,cl
       sete ah
       
       CMP bl,dl
       setge bh
       CMP bl,ch
       setle dh
       AND bh,dh
       
       AND ah,bh
       OR [output_logic],ah
 
 
       ADD bl,13
       
       CMP al,cl
       sete ah
       
       CMP bl,dl
       setge bh
       CMP bl,ch
       setle dh
       AND bh,dh
       
       AND ah,bh
       OR [output_logic],ah
       
       POPA
       RET


check_collision:
                PUSH ax
                PUSH bx
                MOV bx,chick_many
                JMP checking
checking:                
         CMP BYTE [bx],0xf1
         JE next_chkmany
         
         MOV ah,[bx+1]
         MOV [var1],ah
         MOV al,[bx]
         MOV [var2],al
         
         MOV ah,[si+1]
         MOV [constant_cmp1],ah
         MOV al,[si]
         MOV [constant_cmp2],al
         
         CALL cmp_and   
         CMP BYTE [output_logic],1
         JNE next_chkmany
         
         
         
        ; MOV ah,[bx+1]
        ; CMP BYTE [si+1],ah
        ; JNE next_chkmany
         
        ; MOV al,[bx]
        ; CMP BYTE [si],al
        ; JNE next_chkmany
         
         
         PUSH si
         PUSH bx
         MOV ah,[bx]
         MOV al,[bx+1]
         CALL chick1clear
         POP bx
         POP si


         MOV BYTE [bx],0xf1
         MOV BYTE [si],0xf1
         MOV BYTE [si+2],1
         MOV BYTE [dec_y],1
         DEC BYTE [total_chickmany]
         JMP end_check_collision
         
next_chkmany:
             INC bx
             INC bx
             CMP BYTE [bx],0xff
             JE end_check_collision
             JMP checking
             
end_check_collision:
                    POP bx
                    POP ax
                    RET
             
             
                
                
                
                




render_weapons:
               PUSHA

              ; MOV si,bullet_trogectry           ;NOP just example 
               CALL unknown4

               JMP weapon_loop

weapon_loop:
            CMP BYTE [si],0xf1
            JE next_render

            MOV ah,[si]
            MOV al,[si+1]
            CMP BYTE [render_choice],'b'
            JE clear_previous_bullet
            CMP BYTE [render_choice],'e'
            JE clear_previous_eggs
            CALL continue_render
            JMP next_render

clear_previous_bullet:
                      CMP BYTE [si+2],1
                      JE dont_clear
                      CMP BYTE [si+1],2
                      JLE reset_weapon
                      CALL continue_render
                      CALL check_collision
                      CMP BYTE [dec_y],1
                      JE nonedec
                      DEC BYTE [si+1]
                      JMP next_render
nonedec:
        MOV BYTE [dec_y],0
        JMP next_render

clear_previous_eggs:
                    CMP BYTE [si+2],1
                    JE dont_clear
                    CMP BYTE [si+1],14
                    JGE reset_weapon
                    CALL continue_render
                    INC BYTE [si+1]
                    JMP next_render

reset_weapon:
             MOV BYTE [si],0xf1
             MOV BYTE [si+2],1
             CALL continue_render
             JMP next_render

dont_clear:
           MOV BYTE [si+2],0
           JMP next_render


continue_render:
                PUSH si
                CALL unknown3   ; eg:   CALL bullet_drawer
                POP si
                RET

next_render:
            INC si
            INC si
            INC si
            CMP BYTE [si],0xff
            JE end_render_weapons
            JMP weapon_loop


end_render_weapons:
                   POPA
                   RET














draw_all:
         PUSHA
         MOV si,chick_many
         JMP ch_loop

ch_loop:
         CMP BYTE [si],0xf1
         JE next_ch_loop
          
         MOV ah,[si]
         MOV al,[si+1]
         
         PUSH si                  
         CALL unknown3      ; eg:  CALL chick1drawer
         POP si
         
         JMP next_ch_loop
          
next_ch_loop:
             INC si
             INC si
             CMP BYTE [si],0xff
             JE end_draw_all   
             JMP ch_loop


end_draw_all:
             POPA
             RET
             
             







change_chicken_state:
                     CMP BYTE [switch_count],1
                     JE again_chk_second_state
                     JMP first_code_block

again_chk_second_state:
                       CMP BYTE [state_count],1
                       JE second_code_block
                       JMP first_code_block

first_code_block:
                 CMP BYTE [state_count],1
                 JE fblock_i
                 DEC BYTE [state_count]
                 CMP BYTE [state],1
                 JE anidecy
                 INC BYTE [anime_relative_xy+1]
                 JMP end_change_chicken_state
anidecy:
        DEC BYTE [anime_relative_xy+1]
        JMP end_change_chicken_state


fblock_i:
        ; MOV BYTE [anime_relative_xy],0   ;NOP xnot needed
         MOV BYTE [anime_relative_xy+1],0
         DEC BYTE [switch_count]
         MOV BYTE [state_count],3
         XOR BYTE [state],1
         JMP end_change_chicken_state


second_code_block:
                  CMP BYTE [diagonal_count],1
                  JE sblocki
                  CMP BYTE [diagonal_count],3
                  JE sblockiii
                  INC BYTE [diagonal_count]
                  CALL anidiagxy
                  JMP end_change_chicken_state

anidiagxy:
          CMP BYTE [diagonal_state],1
          JE diagdecxy
          INC BYTE [anime_relative_xy]
          DEC BYTE [anime_relative_xy+1]
          RET

diagdecxy:
          DEC BYTE [anime_relative_xy]
          DEC BYTE [anime_relative_xy+1]
          RET

sblocki:
        MOV BYTE [anime_relative_xy+1],0
        MOV BYTE [state],0
        INC BYTE [diagonal_count]
        CALL anidiagxy
        JMP end_change_chicken_state


sblockiii:
          MOV BYTE [anime_relative_xy],0
          MOV BYTE [anime_relative_xy+1],0
          XOR BYTE [diagonal_state],1
          MOV BYTE [diagonal_count],1
          MOV BYTE [switch_count],3
          MOV BYTE [state_count],3
          JMP end_change_chicken_state

end_change_chicken_state:
                         PUSHA
                         MOV si,chick_many
                         MOV ah,[anime_relative_xy]
                         MOV al,[anime_relative_xy+1]
                         JMP merge_chick_many
merge_chick_many:
                 CMP BYTE [si],0xf1
                 JE next_merge_chick_many
                 ADD [si],ah
                 ADD [si+1],al
                 JMP next_merge_chick_many
                 
next_merge_chick_many:                 
                      INC si
                      INC si
                      CMP BYTE [si],0xff
                      JE end_chg_chs
                      JMP merge_chick_many

end_chg_chs:
            POPA
            RET






init_trogectry:
               PUSH si
               MOV si,bullet_trogectry
               JMP trogectry_loop
               
trogectry_loop:               
               CMP BYTE [si],0xf1
               JE save_trogectry
               INC si
               INC si
               INC si
               CMP BYTE [si],0xff
               JE end_save_trogectry
               JMP trogectry_loop
               
save_trogectry:
               PUSH bx
               MOV bl,[shipbody_xy]
               MOV [si],bl
               MOV bl,[shipbody_xy+1]
               DEC bl
               MOV [si+1],bl
               POP bx
               JMP end_save_trogectry
               
end_save_trogectry:               
                   POP si
                   RET




init_egg_trojectory:
                   CMP BYTE [bx_time],1
                   JNE endegtroj
                   PUSH si
                   MOV si,egg_trojectory
                   JMP egtrojectory_loop
               
egtrojectory_loop:               
               CMP BYTE [si],0xf1
               JE save_egtrojectory
               INC si
               INC si
               INC si
               CMP BYTE [si],0xff
               JE end_save_egtrojectory
               JMP egtrojectory_loop
               
save_egtrojectory:
               PUSH bx
               PUSH cx
               XOR cx,cx
 ;  randomkey DB 0
               MOV cl,[randomkey]
               
               MOV bx,chick_many
               
               ADD bx,cx 
               XOR cx,cx
               
               MOV cl,[bx]
               CMP BYTE [si-3],cl
               JE skipsaveegg
               ;ADD cl,4
               MOV [si],cl
               
               MOV cl,[bx+1]
               INC cl
               ;INC cl
               MOV [si+1],cl
               JMP skipsaveegg
skipsaveegg:               
               POP cx
               POP bx
               JMP end_save_egtrojectory
               
               
end_save_egtrojectory:               
                   POP si
                   RET
endegtroj:
          RET






key:
    PUSH ax
    PUSH bx
    MOV ah,0x01
    INT 16h
    JZ no_key
    CMP al,0x20
    JE appendAL   
    MOV ah,0x0
    INT 16h
    JMP exit_key

appendAL:
         MOV BYTE [onclick],al
         MOV ah,0x0
         INT 16h
         POP bx
         POP ax
         RET
         
no_key:
       MOV ah,0x0
       JMP exit_key

exit_key:
         MOV BYTE [onclick],ah
         POP bx
         POP ax
         RET



ship_movement:
              CALL key
              CMP BYTE [onclick],0x4d
              JE rightaction
              CMP BYTE [onclick],0x4b
              JE leftaction
              CMP BYTE [onclick],0x48
              JE upaction
              CMP BYTE [onclick],0x50  
              JE downaction
              CMP BYTE [onclick],0x20
              JE bulletonclick
              CMP BYTE [onclick],0x53
              JE restart_system
              JMP clearonclick
              
rightaction:
            CALL flames_clear_drawer 
            CALL cls_shipdrawer
            INC BYTE [shipbody_xy]
            CALL shipdrawer
            
            CALL randommaker
            CALL reviveflamestate
            JMP clearonclick
           
leftaction:
           CALL flames_clear_drawer 
           CALL cls_shipdrawer
           DEC BYTE [shipbody_xy]
           CALL shipdrawer
           
           CALL randommaker
           CALL reviveflamestate
           JMP clearonclick
          
upaction:
         CALL flames_clear_drawer 
         CALL cls_shipdrawer
         DEC BYTE [shipbody_xy+1]
         CALL shipdrawer
         
         CALL randommaker
         CALL reviveflamestate
         JMP clearonclick
          
downaction:
           CALL flames_clear_drawer 
           CALL cls_shipdrawer
           INC BYTE [shipbody_xy+1]
           CALL shipdrawer
           
           CALL randommaker
           CALL reviveflamestate
           JMP clearonclick

bulletonclick:
              CALL init_trogectry
              CALL randommaker
              JMP clearonclick
  
randommaker:
             ADD BYTE [randomkey],2
             CMP BYTE [randomkey],10
             JL clearonclick
             MOV BYTE [randomkey],0 
             RET
     
restart_system: 
               MOV al,0xfe
               OUT 0x64,al
               INT 16h

clearonclick:
             MOV BYTE [onclick],0
             RET
   
   
   
    
displayhex:
           ;CMP BYTE [bx_time],0x0180
           ;JNE end_displayhex
           PUSH ax
           PUSH cx
           XOR cx,cx
           CALL set_cursor
           ;MOV al,[shipbody_xy+1]
           
           MOV al,[dx_time]
           
           CALL debug_hex
           
           MOV ah,0xe
           MOV al,0x20
           INT 10h
           
           ;MOV al,[shipbody_xy]
           
           MOV al,[bx_time]
           
           CALL debug_hex
           POP cx
           POP ax
           RET
end_displayhex:
               RET


cleanscreen:
            MOV ah,0
            MOV al,3
            INT 10h
            XOR ax,ax
            RET
            
        
        
        
        
        
        
            
check_weapons_clash:
                    CMP BYTE [bx_time],1
                    JNE end_check_clash
                    PUSH si
                    PUSH bx
                    PUSH cx
   
                    MOV bx,egg_trojectory
                    MOV si,bullet_trogectry
                    JMP wepn_eb_collide

wepn_eb_collide:
               CMP BYTE [si],0xf1
               JE next_bullet_check_collide
               CMP BYTE [bx],0xf1
               JE next_bx_collide
               
               PUSH ax
               PUSH dx
               XOR ax,ax
               XOR dx,dx
               
               MOV ch,[si]
               MOV cl,[si+1]
               
               CMP BYTE [bx],ch
               sete ah
               CMP BYTE [bx+1],cl
               sete al
               AND ah,al        ;result ah
               MOV dh,ah        ;save -> dh
               
               
               ADD ch,1
               CMP BYTE [bx],ch
               sete ah
               ;AL already have y_chk
               AND ah,al                   ;result ah
               OR dh,ah
               
               ADD ch,-7                   ;-6
               ADD cl,2                    ;2
               CMP BYTE [bx],ch
               SETE ah
               CMP BYTE [bx+1],cl
               SETE al
               AND ah,al
               OR dh,ah
               
               ADD ch,13
               CMP BYTE [bx],ch
               SETE ah
               AND ah,al         ;al have chk 2+y
               OR dh,ah
               
               CMP dh,1
               JE clearclashtrays
               POP dx
               POP ax
               JMP next_bx_collide      
                     
               
clearclashtrays: 
               POP dx
               POP ax
               
               PUSHA
               XOR ax,ax
               
               MOV ah,[bx]
               MOV al,[bx+1]
               CALL cls_egg_drawer
               MOV BYTE [bx],0xf1
               MOV BYTE [bx+1],0   ;not neccesary
               MOV BYTE [bx+2],1
               
               XOR ax,ax
               
               MOV ah,[si]
               MOV al,[si+1]
               CALL cls_bullet_drawer
               POPA
               MOV BYTE [si],0xf1
               MOV BYTE [si+1],0  ;not neccesary
               MOV BYTE [si+2],1
                              
               JMP next_bullet_check_collide

next_bx_collide:
                INC bx
                INC bx
                INC bx
                CMP BYTE [bx],0xff
                JE next_bullet_check_collide
                JMP wepn_eb_collide
       
       
next_bullet_check_collide:
                          INC si
                          INC si
                          INC si
                          CMP BYTE [si],0xff
                          JE end_bullet_egg_collide_now
                          MOV bx,egg_trojectory
                          JMP wepn_eb_collide
                  
end_bullet_egg_collide_now:
                           POP cx
                           POP bx
                           POP si
                           RET
end_check_clash:
                RET
          



   
;accept bx /modify ax,cx /RESULT AL

checking_ship_crash:
                    XOR ax,ax
                    XOR cx,cx

                    MOV ah,[shipbody_xy]
                    ADD ah,-6                ;-6
                    CMP bh,ah
                    SETGE al
                    ADD ah,13                 ;-7
                    CMP bh,ah
                    SETLE cl

                    AND al,cl               
                    CMP al,1
                    JNE end_ship_clash_chk           ;not in ship vertical domain

                    XOR ax,ax
                    XOR cl,cl
                    MOV ah,[shipbody_xy]

                    CMP bh,ah
                    SETGE al
                    INC ah          ;ah+1
                    CMP bh,ah
                    SETLE cl
                    AND al,cl               ;x_chk AL
                    MOV ah,[shipbody_xy+1]
                    INC ah                   ;y+1
                    CMP bl,ah
                    SETGE cl
                    ADD ah,3              ;y+4
                    CMP bl,ah
                    SETLE ch
                    AND cl,ch                ;y_chk CL
                    AND al,cl                ;1area_chk

 ;already chk(ed) full vertical domain
;already ch have +4  less than chk

                    ADD ah,-1                 ;y+3
                    CMP bl,ah
                    SETGE cl
                    AND cl,ch                ;2area_chk

                    OR al,cl                 ;final intersection result in al
                    JMP end_ship_clash_chk
end_ship_clash_chk:
                   RET 

 
 
 
chk_ship_destroy_by_egg:
                        
                        PUSH si
                        PUSH bx
                        CMP BYTE [bx_time],1
                        JNE end_chk_ship_destroy_by_egg
                        MOV si,egg_trojectory
                        CMP BYTE [si],0xf1
                        JE next_bx_shipegchk 
                        JMP procede_chk_egg
procede_chk_egg:
                MOV bh,[si]
                MOV bl,[si+1]
                PUSH ax
                PUSH cx
                CALL checking_ship_crash
                CMP al,1
                POP cx
                POP ax
                JE end_game
                JMP next_bx_shipegchk
                
next_bx_shipegchk:
                  INC si
                  INC si
                  INC si
                  CMP BYTE [si],0xf1
                  JE next_bx_shipegchk
                  CMP BYTE [si],0xff
                  JE end_chk_ship_destroy_by_egg
                  JMP procede_chk_egg
end_game:
         PUSHA
         MOV ah,2h
         MOV bh,0
         MOV dl,9
         MOV dh,1
         INT 10h
         MOV ah,0xe
         MOV al,'D'
         INT 10h
         MOV al,'E'
         INT 10h
         MOV al,'A'
         INT 10h
         MOV al,'D'
         INT 10h
         POPA
         JMP end_chk_ship_destroy_by_egg
         
                  
end_chk_ship_destroy_by_egg:
                            POP bx
                            POP si
                            RET
                
 
 
 
flames_anime:
             CMP WORD [bx_time],0x00de   ; 0x010a
             JNE flamecls
             CMP BYTE [reviveflamestate_value],1
             JNE flamemul
             CALL flames_plus_drawer
             MOV BYTE [reviveflamestate_value],2
             MOV BYTE [reviveflamestate_value+1],0
             RET
flamemul:
         CALL flames_star_drawer
         MOV BYTE [reviveflamestate_value],1
         MOV BYTE [reviveflamestate_value+1],0
         RET
         
flamecls:
          CMP WORD [bx_time],0x0008
          JNE end_flames_anime
          CALL flames_clear_drawer
          MOV BYTE [reviveflamestate_value+1],1
          RET
           
end_flames_anime:
                 RET
 
 
   
reviveflamestate:
                 CMP BYTE [reviveflamestate_value+1],1
                 JE end_reviveflamestate
                 CMP BYTE [reviveflamestate_value],1
                 JE plus_reviveflamestate
                 CMP BYTE [reviveflamestate_value],2
                 JNE end_reviveflamestate
                 CALL flames_star_drawer
                 RET
plus_reviveflamestate:
                      CALL flames_plus_drawer
                      RET
                      
end_reviveflamestate:
                     RET
            
            
            
            
            
            

startsp:
        CALL cleanscreen
        CALL shipdrawer
        CALL chick_draw_all
        
        PUSH bx
        MOV bx,[bx_time]
        MOV [bx_time_bak],bx
        MOV bx,[dx_time]
        MOV [dx_time_bak],bx
        POP bx
        
        JMP startspc
     
startspc:
         CALL animation_timer 
         CALL displayhex
         CALL ship_movement
         CALL bullet_trogectry_drawer
         CALL cls_bullet_trogectry_drawer
         
         CALL init_egg_trojectory
         CALL egg_trojectory_drawer
         CALL cls_egg_trojectory_drawer
         CALL check_weapons_clash
         CALL chk_ship_destroy_by_egg
         CALL flames_anime
         
         JMP startspc
         
         
halt:
     HLT
     JMP halt         
 
           
bullet DB "....$"
cls_bullet DB "    $"
bullet_relative DB 1,0,-6,2,7,2
bullet_trogectry DB 0xf1,0,1,0xf1,0,1,0xf1,0,1,0xff
dec_y DB 0
render_choice DB 0


randomkey DB 0
egg DB '0'
egg_trojectory DB 0xf1,0,1,0xf1,0,1,0xf1,0,1,0xf1,0,1,0xf1,0,1,0xff


shipbody DB "**||*_/\_*|___/\___||__||__|$"
cls_shipbody DB "                            $"
shipbody_xy DB 0x22,0xa ;0x12
;min_x = 6h   max_x = 48h     min_y = 1h   max_y = 14h
shasm DB 1,0,0,1,1,1,-6,2,-1,2,0,2,1,2,2,2,7,2,-6,3,-5,3,-4,3,-3,3,-2,3,3,3,4,3,5,3,6,3,7,3,-6,4,-5,4,-4,4,-3,4,4,4,5,4,6,4,7,4
flames_star DB "*--***--***-**$"
flames_plus DB "+--+++--+++-++$"
flames_clear DB 0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,'$'

flames_relative_xy DB 1,0,2,0,3,0,-1,1,0,1,1,1,2,1,3,1,4,1,1,2,2,2,3,2,2,3
reviveflamestate_value DB 1,0


bx_time DW 0x0327
dx_time DW 0x001e

bx_time_bak DW 0
dx_time_bak DW 0

onclick DB 0

unknown1_db DW init_temp
unknown2_db DW init_temp
unknown3_db DW init_temp
unknown4_db DW init_temp

chick_down_count DB 16
chick1 DB "/-(o_o)-\V$"
chick1cls DB "          $"
chick1_xy DB 1,0,2,0,3,0,4,0,5,0,6,0,7,0,8,0,4,1
chick_many DB 5,3,18,3,31,3,44,3,57,3,0xff
chick_many_bak DB 5,3,18,3,31,3,44,3,57,3,0xff
total_chickmany DB 5


state DB 0      ;state
state_count DB 3            ; state_ct
switch_count DB 3            ; ch_ct
diagonal_state DB 0           ;ch_d
diagonal_count DB 1            ;chd_n

anime_relative_xy DB 0,0


           
constant_cmp1 DB 0
constant_cmp2 DB 0
var1 DB 0
var2 DB 0    
output_logic DB 0


hex DB 0,0


TIMES 1437952-($-$$) DB 0

;TIMES 2560-($-$$) DB 0
;80×2×18×512=1,474,560 bytes
;DW 0xaa55
;TIMES 1500000 DB 0







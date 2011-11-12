  (script-fu-register
            "extract-contiguous-fragments-of-foreground";func name
            "Extract contiguous fragments of foreground";menu label
            "Extracts foreground fragments of significant size into separate files"              ;description
            "Yegor Alexeyev"                            ;author
            "copyright 2011, Egor Alexeyev"             ;copyright notice
            "November 5, 2011"                          ;date created
            ""                                          ;image type that the script works on
            SF-IMAGE    "Image"         0
            SF-DRAWABLE "Layer to blur" 0
	    SF-COLOR    "Color of background" '(255 0 152)
            SF-COLOR    "Color of background near the fragments" '(255 0 0)
		
  )
  (script-fu-menu-register "extract-contiguous-fragments-of-foreground" "<Image>/File/Create")
  (define (extract-contiguous-fragments-of-foreground image drawable color color_near_the_fragments)
    (plug-in-compose-alpha RUN-NONINTERACTIVE image drawable color)	
    (plug-in-threshold-alpha RUN-NONINTERACTIVE image drawable 115)   
    (plug-in-compose-alpha RUN-NONINTERACTIVE image drawable color_near_the_fragments)
    (plug-in-threshold-alpha RUN-NONINTERACTIVE image drawable 100)
    (do ((y 400 (+ y 10)))
        ((>= y (car (gimp-image-height image))))
      (do ((x 0 (+ x 10)))
          ((>= x (car (gimp-image-width image))))
        (let ((alpha_value (vector-ref (nth 1 (gimp-drawable-get-pixel drawable x y)) 3)))          
          (if (> alpha_value 0)
            (begin  
              (gimp-fuzzy-select-full drawable x y 255 2 FALSE TRUE 5 5 FALSE FALSE 0)
              (if (= (car (gimp-selection-is-empty image)) 0)      
                (let* ((histogram_values  (gimp-histogram drawable 0 0 0))
                       (count_of_non_transparent_pixels (nth 3 histogram_values)))
                      (if (> count_of_non_transparent_pixels 100)
                          (begin
                              (gimp-edit-bucket-fill-full drawable FG-BUCKET-FILL 25 100 255  FALSE TRUE 0 0 0)
                              (gimp-edit-copy drawable)
                              (let* ((image_of_fragment (car (gimp-edit-paste-as-new)))
                                     (drawable_of_fragment (car (gimp-image-get-active-drawable image_of_fragment)))
                                     (filename (string-append (car (gimp-image-get-filename image)) "-fragment-" (number->string x) "-" (number->string y) ".tiff")))
                                    (file-tiff-save RUN-NONINTERACTIVE image_of_fragment drawable_of_fragment filename filename 0)
                              ) 
;Fragment with border pixels not included in saved feathered selection is removed 
                              (gimp-fuzzy-select-full drawable x y 255 2 FALSE FALSE 0 0 FALSE FALSE 0)
                              (if (= (car (gimp-selection-is-empty image)) 0)
                                (gimp-edit-clear drawable)
                              )
                          )
                      )
                )
              )
            )
          )
        )
      )
    )
  )          
      


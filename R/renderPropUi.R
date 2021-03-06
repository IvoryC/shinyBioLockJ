#' General BioLockJ Properties UI
#'
#' As of this writing, the Properties class in BioLockJ has these KNOWN_TYPES:
#' KNOWN_TYPES = {STRING_TYPE, BOOLEAN_TYPE, FILE_PATH, EXE_PATH, LIST_TYPE, FILE_PATH_LIST, INTEGER_TYPE, NUMERTIC_TYPE};
#' KNOWN_TYPES = {"string", "boolean", "file path", "executable", "list", "list of file paths", "integer", "numeric"};
#'  
#' @param propName a property name, such script.numThreads
#' @param prop a property object, which is a list that contains type, description, etc
#' @param default the current default value
#' @param value the current value
#' @param defaults the list of lists of representation of defaults
#' @param ownership the ownership category for the proprety, one of c("general", "shared", "owned", "override")
#' @param moduleId if ownership is not "general", which module is the ownership referenceing
#' @param trailingUI ui element (or tagList of elements) added to the end of the returned property UI, ideal for creating a border between several PropUi elements.
#' @param trailingUiFun a function that takes no args and returns a tagList object
#'
#' @return ui object list
#' 
# render general prop ui ####
renderPropUi <- function(propName, prop, value, defaults, ownership="general", moduleId=NULL, trailingUiFun=function(){tagList(hr())} ){
    if (ownership=="override") message("Treating property ", propName, " as a ", prop$type, " property.")
    uiName = propUiName(propName)
    default = defaults$values[propName]
    if ( !BioLockR::isReadableValue(prop$type) ) prop$type = "string" # this is a stop gap.  All properties **should have $type; see sheepdog_testing_suite issue #318
    if ( !BioLockR::isReadableValue(prop$description) ) prop$description = "a property" # this is a stop gap.  All properties **should have $description
    if(prop$type == "boolean"){
        selected = ""
        if ( BioLockR::isReadableValue(value) ){
            if ( value=="Y" || value=="TRUE" || value==TRUE ) {
                selected = "Y"
            }else if(value=="N" || value=="FALSE" || value==FALSE ){
                selected = "N"
            }
        }
        inputObj <- radioButtons(inputId = uiName,
                                 label = propName,
                                 choices = c(Y="Y", N="N", omit=""),
                                 selected = selected,
                                 inline = TRUE)
    }else if(prop$type == "numeric"){
        inputObj <- numericInput(inputId = uiName,
                                 label = propName,
                                 value = value,
                                 width = '60%')
    }else if(prop$type == "integer"){
        inputObj <- numericInput(inputId = uiName,
                                 label = propName,
                                 value = value,
                                 step = 1,
                                 width = '40%')
    }else if(prop$type == "file path"){
        inputObj <- buildFilePathPropUI(propName, value, default)
    }else if(prop$type == "list of file paths"){
        inputObj <- buildFileListPropUI(propName, value, default)
    }else {
        inputObj <- textInput(inputId = uiName,
                              label = propName,
                              value = value,
                              placeholder = default,
                              width = '100%')
    }
    
    if (ownership=="shared" || ownership=="owned"){
        overrideProp = module_override_prop(propName, moduleId)
        overridOpt <- tagList(
            shinyBS::popify(actionButton( propOverrideBtnId(prop$property, moduleId), "create override"), 
                            title = overrideProp,
                            content = paste0("If the property \"", overrideProp, "\" is present, then its value will be used in place of the value of property \"", propName, "\" but ONLY this module instance."))
        )
    }else if (ownership=="override"){
        overridOpt <- tagList(
            actionLink( propRmOverrideBtnId(prop$property, moduleId), "remove override"), 
            paste0("to resume using: ", prop$property)
        )
    }else{
        overridOpt <- tagList()
    }
    
    trailingUI = trailingUiFun()
    message("trailingUI has length: ", length(trailingUI))
    message("trailingUI looks like this: ", trailingUI)
    
    if (is.null(default)){
        propUI <- tagList(
            em(prop$type),
            renderText(prop$description),
            inputObj,
            overridOpt,
            unlist(trailingUI))
    }else{
        content = "<b>source of default value</b>"
        content = c(content, paste("standard default:", defaults$defaultPropsList$standard[propName]))
        for (name in defaults$activeFiles){
            val = " "
            if (propName %in% names(defaults$defaultPropsList[[name]])){
                val = defaults$defaultPropsList[[name]][propName]
            }
            content = c(content, paste0(name, ": ", val))
        }
        
        propUI <- tagList(
            shinyBS::popify(
                actionLink(propInfoId(propName), "", icon = icon("angle-double-left")),
                title=paste0("<b>", propName, " = ",  defaults$values[propName], "</b>"),
                paste0(content, collapse = "<br>"),#content=paste("default:", defaults$values[[propName]]),
                trigger = c('hover','click'), placement='right'),
            em(prop$type),
            renderText(prop$description),
            inputObj,
            overridOpt,
            trailingUI)
    }
    
    return(propUI)
}
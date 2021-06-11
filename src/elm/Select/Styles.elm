module Select.Styles exposing (clearClass, clearStyles, hiddenMenuStyles, inputClass, inputControlClass, inputControlStyles, inputId, inputStyles, inputWrapperClass, inputWrapperStyles, menuClass, menuItemClass, menuItemStyles, multiInputClass, multiInputItemClass, multiInputItemContainerClass, multiInputItemContainerStyles, multiInputItemStyles, multiInputItemText, multiInputRemoveItem, multiInputStyles, removeItemSvgClass, removeItemSvgStyles, underlineClass, underlineStyles, visibleMenuStyles)

-- INPUT CONSTANTS


inputId : String
inputId =
    "elm-select-input"


inputControlClass : String
inputControlClass =
    "elm-select-input-control "


inputControlStyles : List ( String, String )
inputControlStyles =
    [ ( "position", "relative" )
    , ( "background", "white" )
    ]


inputWrapperClass : String
inputWrapperClass =
    "elm-select-input-wrapper "


inputWrapperStyles : List ( String, String )
inputWrapperStyles =
    [ ( "display", "flex" )
    , ( "flex", "1" )
    , ( "flex-direction", "row" )
    , ( "flex-wrap", "wrap" )
    ]


inputClass : String
inputClass =
    "elm-select-input input"


inputStyles : List ( String, String )
inputStyles =
    []


multiInputClass : String
multiInputClass =
    "elm-select-multi-input "


multiInputStyles : List ( String, String )
multiInputStyles =
    []


multiInputItemContainerClass : String
multiInputItemContainerClass =
    "elm-select-multi-input-item-container "


multiInputItemContainerStyles : List ( String, String )
multiInputItemContainerStyles =
    [ ( "display", "flex" )
    , ( "flex-direction", "row" )
    , ( "align-items", "center" )
    , ( "justify-content", "center" )
    ]


multiInputItemClass : String
multiInputItemClass =
    "elm-select-multi-input-item "


multiInputItemStyles : List ( String, String )
multiInputItemStyles =
    [ ( "display", "flex" )
    , ( "border-width", "0.1rem" )
    , ( "border-radius", "0.2em" )
    , ( "border-color", "#E3E5E8" )
    , ( "background-color", "#E3E5E8" )
    , ( "font-size", ".75rem" )
    , ( "margin-right", ".2rem" )
    ]


multiInputItemText : List ( String, String )
multiInputItemText =
    [ ( "text-overflow", "ellipsis" )
    , ( "padding-left", ".5rem" )
    , ( "padding-right", ".3rem" )
    , ( "padding-top", ".05rem" )
    , ( "padding-bottom", ".05rem" )
    , ( "display", "none" )
    ]


multiInputRemoveItem : List ( String, String )
multiInputRemoveItem =
    [ ( "display", "flex" )
    , ( "alignItems", "center" )
    , ( "justifyContent", "center" )
    , ( "padding-right", ".1rem" )
    ]



-- UNDERLINE


underlineClass : String
underlineClass =
    "elm-select-underline "


underlineStyles : List ( String, String )
underlineStyles =
    []



-- ITEM CONSTANTS


menuItemClass : String
menuItemClass =
    "elm-select-item "


menuItemStyles : List ( String, String )
menuItemStyles =
    [ ( "cursor", "pointer" )
    ]



-- CLEAR CONSTANTS


clearClass : String
clearClass =
    "elm-select-clear "


clearStyles : List ( String, String )
clearStyles =
    [ ( "cursor", "pointer" )
    , ( "height", "1rem" )
    , ( "line-height", "0rem" )
    , ( "margin-top", "-0.5rem" )
    , ( "position", "absolute" )
    , ( "right", "0.25rem" )
    , ( "top", "50%" )
    ]



-- MENU CONSTANTS


menuClass : String
menuClass =
    "elm-select-menu "


visibleMenuStyles : List ( String, String )
visibleMenuStyles =
    [ ( "position", "absolute" ) ]


hiddenMenuStyles : List ( String, String )
hiddenMenuStyles =
    [ ( "display", "none" ) ]



-- REMOVE ITEM CONSTANTS


removeItemSvgClass : String
removeItemSvgClass =
    "elm-select-remove-item "


removeItemSvgStyles : List ( String, String )
removeItemSvgStyles =
    [ ( "cursor", "pointer" )
    ]

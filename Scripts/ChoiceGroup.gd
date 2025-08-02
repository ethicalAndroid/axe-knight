class_name ChoiceGroup extends Control

@export var choices: Array[Choice]

func Choose():
    process_mode = PROCESS_MODE_DISABLED
    visible = false

func Ready():
    for x in choices:
        x.Reset()
    process_mode = PROCESS_MODE_INHERIT
    visible = true
import { Controller } from "stimulus"

export default class extends Controller {
    static targets = ["icon", "spinner"]
    static values = {
        slider: String,
        sliderSource: String,
    }

    connect() {
    }

    openSlider() {
        if (this.hasSliderSourceValue) {
            this.slideinController.open(this.sliderSourceValue)
        } else {
            this.slideinController.open()
        }

    }

    clicked() {
        this.iconTarget.classList.add("hidden")
        this.spinnerTarget.classList.replace("hidden", "block")
    }

    get slideinController() {
        let sliderElement = document.getElementById(this.sliderValue);
        return this.application.getControllerForElementAndIdentifier(sliderElement, "slidein--component")
    }
}

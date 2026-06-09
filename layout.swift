@Row {
    @Column(size: 2) {
        First, you customize your sloth by picking its 
        ``Sloth/power-swift.property``. The power of your sloth influences
        its abilities and how well they cope in their environment. The app
        displays a picker view that showcases the available powers and
        previews your sloth for the selected power.
    }
    
    @Column {
        ![A screenshot of the power picker user interface with four powers displayed – ice, fire, wind, and lightning](slothy-powerPicker)
    }
}

@Row {
    @Column {
        ![A screenshot of the sloth status user interface that indicates the the amount of sleep, fun, and exercise a given sloth is in need of.](slothy-status)
    }
    
    @Column(size: 2) {
        Once you've customized your sloth, it's ready to ready to thrive.
        You'll find that sloths will happily munch on a leaf, but may not be as 
        receptive to working out. Use the activity picker to send some
        encouragement.
    }
}@TabNavigator {
    @Tab("English") {
        ![Two screenshots showing the Slothy app rendering with English language content. The first screenshot shows a sloth map and the second screenshot shows a sloth power picker.](slothy-localization_eng)
    }
    
    @Tab("Chinese") {
        ![Two screenshots showing the Slothy app rendering with Chinese language content. The first screenshot shows a sloth map and the second screenshot shows a sloth power picker.](slothy-localization_zh)
    }
    
    @Tab("Spanish") {
        ![Two screenshots showing the Slothy app rendering with Spanish language content. The first screenshot shows a sloth map and the second screenshot shows a sloth power picker.](slothy-localization_es)
    }
}
@Video(poster: "slothy-hero-poster", source: "slothy-hero", alt: "An animated video showing two screens in the Slothy app. The first screenshot shows a sloth map and the second screenshot shows a sloth power picker.")
@Metadata {
    @CallToAction(purpose: link, url: "https://example.com/slothy-repository")
}
@Metadata {
    @CallToAction(purpose: link, url: "https://example.com/slothy-repository")
    @PageKind(sampleCode)
}
@Links(visualStyle: detailedGrid) {
    - <doc:GettingStarted>
    - <doc:SlothySample>
}
@Metadata {
    @PageImage(
        purpose: card, 
        source: "slothy-card", 
        alt: "Two screenshots showing the Slothy app. The first screenshot shows a sloth map and the second screenshot shows a sloth power picker.")
}
@Metadata {
    @PageImage(
        purpose: icon, 
        source: "slothCreator-icon", 
        alt: "A technology icon representing the SlothCreator framework.")
}
@Metadata {
    @PageColor(green)
}

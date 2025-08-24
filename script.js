class BusinessAdSystem {
    constructor() {
        this.currentAd = null
        this.config = null
        this.container = document.getElementById('businessAdContainer')
        this.progressBar = document.getElementById('progressBar')
        this.businessImage = document.getElementById('businessImage')
        this.businessName = document.getElementById('businessName')
        this.businessStatus = document.getElementById('businessStatus')
        this.businessMessage = document.getElementById('businessMessage')
        this.timerInterval = null
        
        this.initializeConfig()
    }

    async initializeConfig() {
        // Request config from client
        try {
            const response = await fetch(`https://${GetParentResourceName()}/getUIConfig`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            })
            
            if (response.ok) {
                this.config = await response.json()
                this.applyConfigStyles()
            }
        } catch (error) {
            console.warn('Failed to load config, using defaults')
            this.useDefaultConfig()
        }
    }

    useDefaultConfig() {
        this.config = {
            position: 'top-right',
            backgroundColor: 'rgba(15, 23, 42, 0.95)',
            borderColor: 'rgba(51, 65, 85, 1)',
            textColor: '#FFFFFF',
            secondaryTextColor: '#CBD5E1',
            progressBarGradient: { from: '#8B5CF6', to: '#EC4899' },
            animationDuration: 500,
            displayDuration: 8000,
            boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
            hoverShadow: '0 25px 50px -12px rgba(139, 92, 246, 0.2)',
            borderRadius: '8px',
            imageSize: '64px',
            imageBorderRadius: '8px',
            imageBorder: '2px solid rgba(51, 65, 85, 1)',
            imageRing: '2px solid rgba(139, 92, 246, 0.2)'
        }
        this.applyConfigStyles()
    }

    applyConfigStyles() {
        if (!this.config) return

        // Apply position
        this.container.className = `business-ad-container hidden ${this.config.position}`
        
        // Apply dynamic styles
        const style = document.createElement('style')
        style.textContent = `
            .business-ad-container {
                background: ${this.config.backgroundColor} !important;
                border-color: ${this.config.borderColor} !important;
                border-radius: ${this.config.borderRadius} !important;
                box-shadow: ${this.config.boxShadow} !important;
                transition-duration: ${this.config.animationDuration}ms !important;
            }
            
            .business-ad-container:hover {
                box-shadow: ${this.config.hoverShadow} !important;
            }
            
            .business-name {
                color: ${this.config.textColor} !important;
            }
            
            .business-message {
                color: ${this.config.secondaryTextColor} !important;
            }
            
            .business-image {
                width: ${this.config.imageSize} !important;
                height: ${this.config.imageSize} !important;
                border-radius: ${this.config.imageBorderRadius} !important;
                border: ${this.config.imageBorder} !important;
                box-shadow: 0 0 0 2px ${this.config.imageRing.replace('2px solid ', '')} !important;
            }
            
            .progress-fill {
                background: linear-gradient(90deg, ${this.config.progressBarGradient.from}, ${this.config.progressBarGradient.to}) !important;
            }
        `
        document.head.appendChild(style)
    }

    showAd(adData) {
        // Clear any existing ad
        this.closeAd()

        // Set ad content
        this.businessImage.src = adData.image || adData.imageUrl || 'https://via.placeholder.com/64x64'
        this.businessImage.alt = adData.name || adData.businessName || 'Business'
        this.businessName.textContent = adData.name || adData.businessName || 'Business'
        this.businessMessage.textContent = adData.message || ''

        // Set status badge
        const status = adData.status || 'Open'
        const statusType = adData.statusType || status.toLowerCase().replace(/\s+/g, '_')
        this.businessStatus.textContent = status
        this.businessStatus.className = `status-badge ${statusType}`

        // Show the ad
        this.container.classList.remove('hidden')
        this.container.classList.add('visible')

        // Start progress timer
        const duration = adData.duration || this.config?.displayDuration || 8000
        this.startTimer(duration)

        this.currentAd = adData

        // Notify client that ad is shown
        this.notifyAdShown(adData.id)
    }

    startTimer(duration) {
        // Reset progress bar
        this.progressBar.style.transition = 'none'
        this.progressBar.style.transform = 'scaleX(1)'
        
        // Force reflow
        this.progressBar.offsetHeight
        
        // Start animation
        this.progressBar.style.transition = `transform ${duration}ms linear`
        this.progressBar.style.transform = 'scaleX(0)'

        // Set timer to close ad
        this.timerInterval = setTimeout(() => {
            this.closeAd()
        }, duration)
    }

    closeAd() {
        if (this.timerInterval) {
            clearTimeout(this.timerInterval)
            this.timerInterval = null
        }

        this.container.classList.remove('visible')
        this.container.classList.add('hidden')

        // Reset progress bar after animation
        setTimeout(() => {
            if (this.container.classList.contains('hidden')) {
                this.progressBar.style.transition = 'none'
                this.progressBar.style.transform = 'scaleX(1)'
            }
        }, this.config?.animationDuration || 500)

        // Notify client that ad is closed
        if (this.currentAd) {
            this.notifyAdClosed(this.currentAd.id)
        }

        this.currentAd = null
    }

    notifyAdShown(adId) {
        if (typeof GetParentResourceName !== 'undefined') {
            fetch(`https://${GetParentResourceName()}/adShown`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ adId: adId })
            }).catch(() => {}) // Ignore errors
        }
    }

    notifyAdClosed(adId) {
        if (typeof GetParentResourceName !== 'undefined') {
            fetch(`https://${GetParentResourceName()}/adClosed`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ adId: adId })
            }).catch(() => {}) // Ignore errors
        }
    }

    // FiveM Integration Methods
    registerNUICallbacks() {
        window.addEventListener('message', (event) => {
            const data = event.data

            switch (data.action) {
                case 'showBusinessAd':
                    this.showAd(data.adData)
                    break
                case 'closeBusinessAd':
                    this.closeAd()
                    break
                case 'updateConfig':
                    this.config = data.config
                    this.applyConfigStyles()
                    break
            }
        })
    }
}

// Initialize the system
const businessAds = new BusinessAdSystem()

// Register FiveM callbacks
businessAds.registerNUICallbacks()

// Global functions for backward compatibility
function showBusinessAd(adData) {
    businessAds.showAd(adData)
}

function closeAd() {
    businessAds.closeAd()
}

// ESC key to close ad (for testing)
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        businessAds.closeAd()
    }
})
document.addEventListener('DOMContentLoaded', function() {
    
    const mobileMenuBtn = document.getElementById('mobileMenuBtn');
    const navLinks = document.getElementById('navLinks');
    const navbar = document.getElementById('navbar');
    
    if (mobileMenuBtn && navLinks) {
        mobileMenuBtn.addEventListener('click', function() {
            this.classList.toggle('active');
            navLinks.classList.toggle('active');
        });
        
        document.querySelectorAll('.nav-links a').forEach(link => {
            link.addEventListener('click', () => {
                mobileMenuBtn.classList.remove('active');
                navLinks.classList.remove('active');
            });
        });
    }
    
    if (navbar) {
        window.addEventListener('scroll', function() {
            if (window.scrollY > 50) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        });
    }
    
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
            }
        });
    }, observerOptions);
    
    document.querySelectorAll('.animate-on-scroll').forEach(el => {
        observer.observe(el);
    });
    
    const contactForm = document.getElementById('contactForm');
    if (contactForm) {
        contactForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const formData = new FormData(this);
            const name = formData.get('name');
            const email = formData.get('email');
            const phone = formData.get('phone');
            const subject = formData.get('subject');
            const message = formData.get('message');
            
            const formMessage = document.getElementById('formMessage');
            
            if (!name || !email || !subject || !message) {
                formMessage.textContent = 'Please fill in all required fields.';
                formMessage.className = 'form-message error';
                return;
            }
            
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                formMessage.textContent = 'Please enter a valid email address.';
                formMessage.className = 'form-message error';
                return;
            }
            
            formMessage.textContent = 'Thank you for your message! We will get back to you soon.';
            formMessage.className = 'form-message success';
            
            this.reset();
            
            setTimeout(() => {
                formMessage.className = 'form-message';
            }, 5000);
        });
    }
    
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
    
    const yearSpan = document.getElementById('currentYear');
    if (yearSpan) {
        yearSpan.textContent = new Date().getFullYear();
    }
    
    const galleryItems = document.querySelectorAll('.gallery-item');
    galleryItems.forEach(item => {
        item.addEventListener('click', function() {
            const img = this.querySelector('img');
            if (img) {
                openLightbox(img.src, img.alt);
            }
        });
    });
    
    function openLightbox(src, alt) {
        const lightbox = document.createElement('div');
        lightbox.className = 'lightbox';
        lightbox.innerHTML = `
            <div class="lightbox-content">
                <span class="lightbox-close">&times;</span>
                <img src="${src}" alt="${alt}">
            </div>
        `;
        
        lightbox.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.9);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 2000;
            cursor: pointer;
            animation: fadeIn 0.3s ease;
        `;
        
        const lightboxContent = lightbox.querySelector('.lightbox-content');
        lightboxContent.style.cssText = `
            position: relative;
            max-width: 90%;
            max-height: 90%;
        `;
        
        const img = lightbox.querySelector('img');
        img.style.cssText = `
            max-width: 100%;
            max-height: 90vh;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.5);
        `;
        
        const closeBtn = lightbox.querySelector('.lightbox-close');
        closeBtn.style.cssText = `
            position: absolute;
            top: -40px;
            right: 0;
            color: white;
            font-size: 2.5rem;
            cursor: pointer;
            transition: transform 0.3s ease;
        `;
        closeBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            closeLightbox(lightbox);
        });
        closeBtn.addEventListener('mouseenter', () => {
            closeBtn.style.transform = 'rotate(90deg)';
        });
        closeBtn.addEventListener('mouseleave', () => {
            closeBtn.style.transform = 'rotate(0deg)';
        });
        
        lightbox.addEventListener('click', function(e) {
            if (e.target === lightbox) {
                closeLightbox(lightbox);
            }
        });
        
        document.body.appendChild(lightbox);
        document.body.style.overflow = 'hidden';
    }
    
    function closeLightbox(lightbox) {
        lightbox.style.animation = 'fadeOut 0.3s ease';
        setTimeout(() => {
            lightbox.remove();
            document.body.style.overflow = '';
        }, 300);
    }
    
    const style = document.createElement('style');
    style.textContent = `
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        @keyframes fadeOut {
            from { opacity: 1; }
            to { opacity: 0; }
        }
    `;
    document.head.appendChild(style);
    
    const cards = document.querySelectorAll('.service-card, .mv-card, .unit-card, .value-item');
    cards.forEach((card, index) => {
        card.style.transitionDelay = `${index * 0.1}s`;
    });

    const categoryBtns = document.querySelectorAll('.category-btn');
    const teachingCards = document.querySelectorAll('.teaching-card');

    if (categoryBtns.length > 0) {
        categoryBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                categoryBtns.forEach(b => b.classList.remove('active'));
                this.classList.add('active');
                const category = this.dataset.category;

                teachingCards.forEach(card => {
                    if (category === 'all' || card.dataset.category === category) {
                        card.style.display = 'block';
                        setTimeout(() => {
                            card.style.opacity = '1';
                            card.style.transform = 'translateY(0)';
                        }, 50);
                    } else {
                        card.style.opacity = '0';
                        card.style.transform = 'translateY(20px)';
                        setTimeout(() => {
                            card.style.display = 'none';
                        }, 300);
                    }
                });
            });
        });
    }

    let lastScrollTop = 0;
    window.addEventListener('scroll', function() {
        let scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        
        if (scrollTop > lastScrollTop && scrollTop > 100) {
            navbar.style.transform = 'translateY(-100%)';
        } else {
            navbar.style.transform = 'translateY(0)';
        }
        lastScrollTop = scrollTop;
    });
    
    console.log('Website loaded successfully!');
});

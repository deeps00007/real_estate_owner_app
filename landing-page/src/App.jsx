import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Mic, Play, MessageSquare, Map, Bell, ShieldCheck, ChevronRight,
  X, Star, Zap, Heart, Building2, Users, ArrowUpRight, Menu,
  CheckCheck, Smartphone, Video, Lock, BarChart3, Globe, Crown, UserCircle2
} from 'lucide-react';

/* ── Images ──────────────────────────────────── */
import homeScreen from './assets/img/home-screen.jpeg';
import mapScreen from './assets/img/Map-screen-with-property.jpeg';
import propDetail1 from './assets/img/property-detail-page1.jpeg';
import propDetail2 from './assets/img/property-detail-page2.jpeg';
import ownerProfile from './assets/img/Owner-profile-page.jpeg';
import userProfile from './assets/img/user-profile-page.jpeg';
import myProperty from './assets/img/my-property.jpeg';
import addProp1 from './assets/img/Add-property-owner1.jpeg';
import pushNotif from './assets/img/push-notification-broadcast-ownerside.jpeg';
import appLogo from './assets/img/real_estate-logo.png';
/* ── Motion preset ────────────────────────────── */
const fUp = (d = 0) => ({
  initial: { opacity: 0, y: 32 },
  whileInView: { opacity: 1, y: 0 },
  viewport: { once: true },
  transition: { duration: 0.65, delay: d, ease: [0.22, 1, 0.36, 1] },
});

/* ── Ticker ───────────────────────────────────── */
const TAGS = ['Voice AI Search', 'Story Video Player', 'Live Agent Chat', 'Smart Map', 'Rich Push Alerts', 'Owner Dashboard', 'White-Label Ready', 'Firebase Powered'];
const Ticker = () => (
  <div className="overflow-hidden py-4 border-y border-white/5 bg-[#050d1c]">
    <div className="ticker-track flex gap-14 whitespace-nowrap w-max">
      {[...TAGS, ...TAGS].map((t, i) => (
        <span key={i} className="text-xs font-bold uppercase tracking-[0.18em] text-gray-500 flex items-center gap-3">
          <span className="text-yellow-400 text-sm">✦</span>{t}
        </span>
      ))}
    </div>
  </div>
);

/* ── Phone Frame ──────────────────────────────── */
const Phone = ({ src, alt, className = '' }) => (
  <div className={`relative shrink-0 ${className}`}>
    <div className="w-[230px] rounded-[38px] border-[6px] border-white/10 overflow-hidden
      shadow-[0_30px_80px_rgba(0,0,0,0.65)]" style={{ background: '#111' }}>
      <img src={src} alt={alt} className="w-full object-cover" />
    </div>
    <div className="absolute -bottom-6 left-1/2 -translate-x-1/2 w-32 h-10 bg-blue-500/15 blur-2xl rounded-full" />
  </div>
);


const ScreenCarousel = ({ images }) => {
  const items = [
    { src: images.homeScreen, label: 'Home Screen' },
    { src: images.mapScreen, label: 'Map View' },
    { src: images.propDetail1, label: 'Property Detail' },
    { src: images.propDetail2, label: 'Property Gallery' },
    { src: images.ownerProfile, label: 'Owner Profile' },
    { src: images.userProfile, label: 'User Profile' },
    { src: images.myProperty, label: 'My Properties' },
    { src: images.addProp1, label: 'Add Property' },
    { src: images.pushNotif, label: 'Push Broadcast' },
  ];

  const doubled = [...items, ...items];
  const [paused, setPaused] = React.useState(false);
  const [lightbox, setLightbox] = React.useState(null); // index into `items`

  // Keyboard navigation inside lightbox
  React.useEffect(() => {
    if (lightbox === null) return;
    const handler = (e) => {
      if (e.key === 'ArrowRight') setLightbox(i => (i + 1) % items.length);
      if (e.key === 'ArrowLeft') setLightbox(i => (i - 1 + items.length) % items.length);
      if (e.key === 'Escape') setLightbox(null);
    };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [lightbox]);

  return (
    <>
      <section className="py-20 relative overflow-hidden">
        <div className="orb w-[500px] h-[500px] bg-blue-700/10 top-0 left-1/2 -translate-x-1/2 -translate-y-1/2" />

        {/* Heading */}
        <div className="text-center mb-12 px-6 relative z-10">
          <motion.p {...fUp(0)} className="text-yellow-400 text-[11px] font-bold uppercase tracking-[0.2em] mb-3">
            Live Previews
          </motion.p>
          <motion.h2 {...fUp(0.1)} className="text-4xl font-black tracking-tight">
            Every Screen, <span className="gold-text">At a Glance.</span>
          </motion.h2>
          <motion.p {...fUp(0.2)} className="text-gray-400 text-sm mt-3">
            Hover to pause · Click any screen to open full preview
          </motion.p>
        </div>

        {/* Scrolling strip */}
        <div
          className="relative z-10 overflow-hidden py-4"
          onMouseEnter={() => setPaused(true)}
          onMouseLeave={() => setPaused(false)}
        >
          {/* Fade edges with blur mask */}
          <div className="pointer-events-none absolute inset-y-0 left-0 w-28 z-10
            backdrop-blur-md [-webkit-mask-image:linear-gradient(to_right,black,transparent)] [mask-image:linear-gradient(to_right,black,transparent)]" />
          <div className="pointer-events-none absolute inset-y-0 right-0 w-28 z-10
            backdrop-blur-md [-webkit-mask-image:linear-gradient(to_left,black,transparent)] [mask-image:linear-gradient(to_left,black,transparent)]" />

          <div
            className="flex gap-6 w-max px-6"
            style={{
              animation: 'carouselScroll 38s linear infinite',
              animationPlayState: paused ? 'paused' : 'running',
            }}
          >
            {doubled.map((item, i) => (
              <button
                key={i}
                onClick={() => setLightbox(i % items.length)}
                className="flex flex-col items-center gap-2.5 shrink-0 group focus:outline-none"
              >
                <div
                  className="w-[148px] rounded-[30px] border-[4px] border-white/10 overflow-hidden
                  shadow-[0_16px_45px_rgba(0,0,0,0.5)] transition-all duration-300
                  group-hover:scale-105 group-hover:border-yellow-400/40
                  group-hover:shadow-[0_20px_55px_rgba(255,215,0,0.18)]"
                >
                  <img src={item.src} alt={item.label} className="w-full object-cover" draggable={false} />
                </div>
                <span className="text-[11px] text-gray-500 font-semibold group-hover:text-yellow-400 transition-colors tracking-wide">
                  {item.label}
                </span>
              </button>
            ))}
          </div>
        </div>
      </section>

      {/* ── LIGHTBOX ─────────────────────────────────────── */}
      <AnimatePresence>
        {lightbox !== null && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-[200] flex items-center justify-center bg-black/92 backdrop-blur-md"
            onClick={() => setLightbox(null)}
          >
            {/* Container */}
            <motion.div
              initial={{ scale: 0.88, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.88, opacity: 0 }}
              transition={{ type: 'spring', stiffness: 320, damping: 32 }}
              className="relative flex flex-col items-center gap-5"
              onClick={e => e.stopPropagation()}
            >
              {/* Label + close */}
              <div className="flex items-center justify-between w-full px-1">
                <span className="text-yellow-400 font-bold text-sm tracking-wide">
                  {items[lightbox].label}
                </span>
                <button
                  onClick={() => setLightbox(null)}
                  className="w-8 h-8 rounded-full glass flex items-center justify-center text-gray-400 hover:text-white transition-colors"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              {/* Phone frame + image */}
              <AnimatePresence mode="wait">
                <motion.div
                  key={lightbox}
                  initial={{ opacity: 0, x: 40 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -40 }}
                  transition={{ duration: 0.25, ease: [0.22, 1, 0.36, 1] }}
                  className="w-[280px] rounded-[40px] border-[6px] border-white/15
                  overflow-hidden shadow-[0_40px_100px_rgba(0,0,0,0.8)]"
                >
                  <img
                    src={items[lightbox].src}
                    alt={items[lightbox].label}
                    className="w-full object-cover"
                    draggable={false}
                  />
                </motion.div>
              </AnimatePresence>

              {/* Prev / Next */}
              <div className="flex items-center gap-4 mt-1">
                <button
                  onClick={() => setLightbox(i => (i - 1 + items.length) % items.length)}
                  className="w-11 h-11 rounded-full glass border border-white/10 flex items-center justify-center
                  text-white hover:border-yellow-400/40 hover:text-yellow-400 transition-all"
                >
                  ‹
                </button>

                {/* Dot indicators */}
                <div className="flex gap-1.5">
                  {items.map((_, i) => (
                    <button
                      key={i}
                      onClick={() => setLightbox(i)}
                      className={`rounded-full transition-all duration-200 ${i === lightbox
                        ? 'w-5 h-2 bg-yellow-400'
                        : 'w-2 h-2 bg-white/20 hover:bg-white/40'
                        }`}
                    />
                  ))}
                </div>

                <button
                  onClick={() => setLightbox(i => (i + 1) % items.length)}
                  className="w-11 h-11 rounded-full glass border border-white/10 flex items-center justify-center
                  text-white hover:border-yellow-400/40 hover:text-yellow-400 transition-all"
                >
                  ›
                </button>
              </div>

              <p className="text-gray-600 text-xs">Use ← → arrow keys to navigate · ESC to close</p>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
};


/* ── Feature Row ──────────────────────────────── */
const FeatureRow = ({ tag, heading, sub, bullets, img, alt, reverse = false, delay = 0 }) => (
  <div className={`flex flex-col ${reverse ? 'lg:flex-row-reverse' : 'lg:flex-row'} items-center gap-14`}>
    <motion.div {...fUp(delay)} className="flex-1">
      <span className="inline-flex items-center gap-1.5 text-[11px] font-bold uppercase tracking-[0.18em]
        text-yellow-400 mb-4">{tag}</span>
      <h3 className="text-3xl font-black tracking-tight mb-4 text-white" dangerouslySetInnerHTML={{ __html: heading }} />
      <p className="text-gray-400 mb-7 leading-relaxed">{sub}</p>
      <ul className="space-y-3">
        {bullets.map((b, i) => (
          <li key={i} className="flex items-start gap-3 text-sm text-gray-300">
            <CheckCheck className="w-4 h-4 text-green-400 shrink-0 mt-0.5" />
            <span>{b}</span>
          </li>
        ))}
      </ul>
    </motion.div>
    <motion.div {...fUp(delay + 0.1)} className="flex-shrink-0 flex justify-center">
      <Phone src={img} alt={alt} className="phone-float" />
    </motion.div>
  </div>
);

/* ── Stat ─────────────────────────────────────── */
const Stat = ({ val, label, icon: Icon, delay }) => (
  <motion.div {...fUp(delay)} className="glass g-card rounded-2xl p-6 flex flex-col gap-1 items-center text-center">
    <div className="w-10 h-10 rounded-full bg-yellow-400/10 flex items-center justify-center mb-2">
      <Icon className="w-5 h-5 text-yellow-400" />
    </div>
    <p className="text-4xl font-black stat-n gold-text">{val}</p>
    <p className="text-gray-400 text-xs font-medium">{label}</p>
  </motion.div>
);

/* ── Pricing ──────────────────────────────────── */
const PricingCard = ({ tier, price, note, features, hot, delay }) => (
  <motion.div {...fUp(delay)}
    className={`g-card rounded-2xl p-8 flex flex-col gap-5 relative overflow-hidden
      ${hot ? 'bg-gradient-to-b from-[#132d5e]/60 to-[#0a1628]/90' : 'glass'}`}>
    {hot && (
      <>
        <div className="absolute top-0 right-0 w-40 h-40 bg-yellow-400/8 rounded-full blur-3xl" />
        <span className="absolute top-4 right-4 text-[10px] font-black uppercase tracking-widest
          bg-yellow-400 text-[#0F2C59] px-3 py-1 rounded-full">⭐ Best Value</span>
      </>
    )}
    <div>
      <p className="text-gray-400 text-sm font-medium mb-1.5">{tier}</p>
      <div className="flex items-end gap-2">
        <span className="text-4xl font-black text-white">{price}</span>
        {note && <span className="text-gray-500 text-sm mb-1">{note}</span>}
      </div>
    </div>
    <ul className="flex flex-col gap-2.5 flex-1">
      {features.map((f, i) => (
        <li key={i} className="flex items-start gap-2.5 text-sm text-gray-300">
          <CheckCheck className="w-4 h-4 text-green-400 shrink-0 mt-0.5" />{f}
        </li>
      ))}
    </ul>
    <button className={`w-full py-3.5 rounded-full text-sm font-bold ${hot ? 'gold-btn' : 'outline-btn'}`}>
      {hot ? 'Get Started Now' : 'Contact Sales'} →
    </button>
  </motion.div>
);

/* ── Testimonial ──────────────────────────────── */
const Testimonial = ({ name, role, text, av, delay }) => (
  <motion.div {...fUp(delay)} className="glass g-card p-6 rounded-2xl flex flex-col gap-4">
    <div className="flex gap-0.5">
      {Array(5).fill(0).map((_, i) => <Star key={i} className="w-4 h-4 fill-yellow-400 text-yellow-400" />)}
    </div>
    <p className="text-gray-300 text-sm leading-relaxed flex-1">"{text}"</p>
    <div className="flex items-center gap-3 pt-3 border-t border-white/5">
      <div className={`w-10 h-10 rounded-full ${av} flex items-center justify-center text-white font-bold text-sm`}>
        {name[0]}
      </div>
      <div>
        <p className="text-white font-semibold text-sm">{name}</p>
        <p className="text-gray-500 text-xs">{role}</p>
      </div>
    </div>
  </motion.div>
);

/* ══════════════════════════════════════════════
   MAIN
══════════════════════════════════════════════ */
export default function App() {
  const [videoOpen, setVideoOpen] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  const gridRef = React.useRef(null);

  useEffect(() => {
    const h = () => setScrolled(window.scrollY > 30);
    window.addEventListener('scroll', h, { passive: true });
    return () => window.removeEventListener('scroll', h);
  }, []);

  const handleMouseMove = (e) => {
    if (!gridRef.current) return;
    const { clientX, clientY } = e;
    gridRef.current.style.setProperty('--mouse-x', `${clientX}px`);
    gridRef.current.style.setProperty('--mouse-y', `${clientY}px`);
  };

  return (
    <div
      className="bg-[#04091a] min-h-screen text-white overflow-x-hidden select-none"
      onMouseMove={handleMouseMove}
    >
      {/* ── GLOBAL INTERACTIVE GRID ── */}
      <div ref={gridRef} className="grid-bg-interactive" />

      {/* ══════ NAV ══════════════════════════════════ */}
      <header className={`fixed top-0 w-full z-50 transition-all duration-300
        ${scrolled ? 'glass shadow-[0_1px_0_rgba(255,255,255,0.05)] py-3' : 'py-5'}`}>
        <div className="max-w-7xl mx-auto px-6 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-white
              flex items-center justify-center shadow-[0_0_20px_rgba(255,200,0,.15)] overflow-hidden p-1">
              <img src={appLogo} alt="Logo" className="w-full h-full object-contain" />
            </div>
            <span className="text-lg font-extrabold tracking-tight">
              Real Estate <span className="gold-text">Application</span>
            </span>
          </div>
          <nav className="hidden md:flex items-center gap-7 text-sm text-gray-400 font-medium">
            {[['Features', '#features'], ['Owner', '#owner'], ['Pricing', '#pricing']].map(([l, h]) => (
              <a key={l} href={h} className="hover:text-white transition-colors">{l}</a>
            ))}
          </nav>
          <div className="hidden md:flex gap-3 items-center">
            <button className="outline-btn text-sm px-5 py-2.5 rounded-full">Contact Sales</button>
            <button className="gold-btn text-sm px-5 py-2.5 rounded-full">Get the App →</button>
          </div>
          <button className="md:hidden text-gray-400 p-1" onClick={() => setMenuOpen(!menuOpen)}>
            {menuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
        </div>
        <AnimatePresence>
          {menuOpen && (
            <motion.div initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }}
              exit={{ opacity: 0, height: 0 }}
              className="glass border-t border-white/5 px-6 pb-5 flex flex-col gap-3 overflow-hidden">
              {[['Features', '#features'], ['Owner', '#owner'], ['Pricing', '#pricing']].map(([l, h]) => (
                <a key={l} href={h} onClick={() => setMenuOpen(false)}
                  className="text-gray-300 hover:text-white py-2 border-b border-white/5 text-sm">{l}</a>
              ))}
              <button className="gold-btn text-sm px-6 py-3 rounded-full mt-2">Get the App →</button>
            </motion.div>
          )}
        </AnimatePresence>
      </header>

      {/* ══════ HERO ═════════════════════════════════ */}
      <section className="relative min-h-screen flex items-center justify-center pt-28 pb-16 px-6 overflow-hidden">
        <div className="orb w-[700px] h-[700px] bg-blue-700/15 -top-48 -left-56" style={{ animation: 'drift 12s ease-in-out infinite' }} />
        <div className="orb w-[500px] h-[500px] bg-yellow-400/6  bottom-0 right-[-120px]" style={{ animation: 'drift 9s ease-in-out infinite alternate' }} />

        <div className="max-w-7xl mx-auto grid lg:grid-cols-2 items-center gap-16 relative z-10">
          {/* Text */}
          <motion.div initial={{ opacity: 0, x: -40 }} animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.9, ease: [0.22, 1, 0.36, 1] }}>
            <div className="inline-flex items-center gap-2 glass border border-yellow-500/20 rounded-full
              px-4 py-1.5 text-[11px] font-bold uppercase tracking-[0.14em] text-yellow-400 mb-7">
              <Zap className="w-3 h-3" /> White-Label Flutter Real Estate App
            </div>
            <h1 className="text-5xl xl:text-6xl font-black leading-[1.06] tracking-[-0.02em] mb-6">
              Your Own Branded <br />
              <span className="shine-text">Property App</span><br />
              in Days.
            </h1>
            <p className="text-gray-400 text-lg leading-relaxed mb-10 max-w-lg">
              Skip 6 months of development. Get a production-ready Flutter real estate app —
              voice AI search, Instagram Reels, live chat, push notifications — and brand it as yours.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 mb-10">
              <button className="gold-btn px-9 py-4 rounded-full text-base flex items-center justify-center gap-2">
                Buy License <ArrowUpRight className="w-5 h-5" />
              </button>
              <button onClick={() => setVideoOpen(true)}
                className="outline-btn px-9 py-4 rounded-full text-base flex items-center justify-center gap-2">
                <span className="w-7 h-7 rounded-full bg-yellow-400/10 flex items-center justify-center">
                  <Play className="w-3.5 h-3.5 text-yellow-400" fill="#FFD700" />
                </span>
                Watch Demo
              </button>
            </div>
            <div className="flex flex-wrap gap-5 text-xs text-gray-500 font-medium">
              <span className="flex items-center gap-1.5"><ShieldCheck className="w-4 h-4 text-green-400" /> Firebase Secured</span>
              <span className="flex items-center gap-1.5"><Users className="w-4 h-4 text-blue-400" /> 10+ Agencies Live</span>
              <span className="flex items-center gap-1.5"><Heart className="w-4 h-4 text-red-400" fill="#f87171" /> 4.9★ Rated</span>
              <span className="flex items-center gap-1.5"><Smartphone className="w-4 h-4 text-purple-400" /> Android Ready</span>
            </div>
          </motion.div>

          {/* 3-Phone cluster */}
          <motion.div initial={{ opacity: 0, y: 40 }} animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.9, delay: 0.15, ease: [0.22, 1, 0.36, 1] }}
            className="flex items-end justify-center gap-4">
            <div style={{ animation: 'float 7s ease-in-out infinite', transform: 'rotate(-3deg)' }} className="mb-[-20px]">
              <Phone src={homeScreen} alt="Home Screen" className="w-[180px]" />
            </div>
            <div style={{ animation: 'float 6s ease-in-out .5s infinite' }} >
              <Phone src={mapScreen} alt="Map Screen" className="w-[210px]" />
            </div>
            <div style={{ animation: 'float 8s ease-in-out 1s infinite', transform: 'rotate(3deg)' }} className="mb-[-20px]">
              <Phone src={propDetail1} alt="Property Detail" className="w-[180px]" />
            </div>
          </motion.div>
        </div>
        <div className="pointer-events-none absolute bottom-0 left-0 right-0 h-32 z-10
          backdrop-blur-md [-webkit-mask-image:linear-gradient(to_top,black,transparent)] [mask-image:linear-gradient(to_top,black,transparent)]" />
      </section>

      {/* ── TICKER ──────────────────────────────────── */}
      <Ticker />

      {/* ══════ SCREEN CAROUSEL ══════════════════════ */}
      <ScreenCarousel images={{ homeScreen, mapScreen, propDetail1, propDetail2, ownerProfile, userProfile, myProperty, addProp1, pushNotif }} />

      {/* ══════ FEATURES SHOWCASE ════════════════════ */}
      <section id="features" className="py-28 px-6 relative">
        <div className="orb w-[500px] h-[500px] bg-blue-800/10 top-0 right-[-100px]" />
        <div className="max-w-7xl mx-auto relative z-10 space-y-28">

          <div className="text-center mb-4">
            <motion.p {...fUp(0)} className="text-yellow-400 text-[11px] font-bold uppercase tracking-[0.2em] mb-3">
              Feature Showcase
            </motion.p>
            <motion.h2 {...fUp(0.1)} className="text-4xl sm:text-5xl font-black tracking-tight">
              Real Screenshots. <span className="gold-text">Real Features.</span>
            </motion.h2>
          </div>

          {/* Home Screen */}
          <FeatureRow
            tag="🏠 Home Screen"
            heading="Smart Discovery,<br/>Voice-Powered Search"
            sub="Users land on a beautiful property feed showing Best Offers and Nearest Properties. A rotating animated search bar hints at popular categories, and a single tap of the mic activates the AI voice search with a custom waveform animation."
            bullets={[
              'Rotating search bar: "Apartment" → "Villa" → "Office"',
              'Voice mic with live waveform visualizer',
              'Location-aware header with GPS address',
              'Floating Instagram Reel story player (draggable)',
            ]}
            img={homeScreen} alt="Home Screen"
            delay={0}
          />

          {/* Map */}
          <FeatureRow
            tag="🗺️ Map Screen"
            heading="Every Property,<br/>Pinned on the Map"
            sub="Buyers explore a fully interactive map with property image-pins. Tap any pin to see a quick card with price, rating, and distance. The bottom search bar enables voice-dictated or typed map searches in real time."
            bullets={[
              'Property photo-pins on an interactive OSM map',
              'Tap pin → see instant property preview card',
              'Current location awareness + GPS zoom',
              'Voice search overlaid directly on map',
            ]}
            img={mapScreen} alt="Map Screen"
            reverse delay={0.05}
          />

          {/* Property Detail */}
          <FeatureRow
            tag="🏡 Property Detail"
            heading="Rich Details,<br/>One Tap to Connect"
            sub="The property detail page is a clean, image-first layout. Swipeable photo gallery, amenities grid (beds, baths, sqft, kitchen), listing agent info, and a prominent 'Rent Now' / 'Chat with Agent' CTA at the bottom bar."
            bullets={[
              'Full-width hero image with back + favourite buttons',
              'Swipeable photo gallery strip',
              'Amenities grid: Beds, Baths, Sqft, Kitchen',
              'Chat with Agent button → opens real-time chat',
            ]}
            img={propDetail1} alt="Property Detail"
            delay={0.05}
          />
        </div>
      </section>

      {/* ══════ OWNER vs USER ═════════════════════════ */}
      <section id="owner" className="py-28 px-6 relative overflow-hidden">
        <div className="orb w-[700px] h-[700px] bg-yellow-400/4 top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2" />
        <div className="orb w-[400px] h-[400px] bg-blue-700/10 top-0 right-[-100px]" />

        <div className="max-w-7xl mx-auto relative z-10">

          {/* ── Heading ── */}
          <div className="text-center mb-14">
            <motion.p {...fUp(0)} className="text-yellow-400 text-[11px] font-bold uppercase tracking-[0.2em] mb-3">
              Role-Based Access Control
            </motion.p>
            <motion.h2 {...fUp(0.1)} className="text-4xl sm:text-5xl font-black tracking-tight mb-4">
              Owner vs Buyer — <span className="gold-text">Unified Architecture.</span>
            </motion.h2>
            <motion.p {...fUp(0.2)} className="text-gray-400 max-w-2xl mx-auto text-base leading-relaxed">
              No need to manage a separate admin dashboard. Simply assign owner privileges via Firebase,
              and the application dynamically unlocks a comprehensive suite of management tools.
            </motion.p>
          </div>

          {/* ── Tab selector (with inline state) ── */}
          {(() => {
            const [tab, setTab] = React.useState('owner');
            const isOwner = tab === 'owner';

            const ownerFeatures = [
              { icon: '🏠', label: 'My Properties', desc: 'Manage all listings with edit & delete controls' },
              { icon: '➕', label: 'Add New Property', desc: 'Full form: image, price, type, amenities, location' },
              { icon: '📣', label: 'Batch Push Broadcast', desc: 'Send rich notifications with images to all users in batches' },
              { icon: '⚙️', label: 'Owner Tools Panel', desc: 'Exclusive section visible only in admin profile' },
              { icon: '📊', label: 'Listing Insights', desc: 'See how many users saved or viewed your properties' },
            ];
            const userFeatures = [
              { icon: '🏡', label: 'Browse Properties', desc: 'Discover best offers and nearest properties on home' },
              { icon: '❤️', label: 'Save Properties', desc: 'Wishlist any property and revisit anytime' },
              { icon: '💬', label: 'Chat with Agent', desc: 'Open WhatsApp-style real-time chat from property detail' },
              { icon: '🕐', label: 'Recently Viewed', desc: 'Instantly revisit properties you\'ve explored' },
              { icon: '🗺️', label: 'Explore on Map', desc: 'Tap markers to preview property cards on the map' },
            ];

            return (
              <>
                {/* Tab pills */}
                <motion.div {...fUp(0.15)} className="flex justify-center mb-10">
                  <div className="glass g-card inline-flex rounded-2xl p-1.5 gap-1">
                    <button
                      onClick={() => setTab('owner')}
                      className={`flex items-center gap-2 px-6 py-2.5 rounded-xl text-sm font-bold transition-all duration-300 ${isOwner
                        ? 'bg-gradient-to-r from-yellow-400 to-orange-500 text-[#0F2C59] shadow-[0_0_20px_rgba(255,215,0,0.35)]'
                        : 'text-gray-400 hover:text-white'
                        }`}
                    >
                      <Crown className="w-4 h-4" /> Owner / Admin
                    </button>
                    <button
                      onClick={() => setTab('buyer')}
                      className={`flex items-center gap-2 px-6 py-2.5 rounded-xl text-sm font-bold transition-all duration-300 ${!isOwner
                        ? 'bg-gradient-to-r from-blue-500 to-blue-700 text-white shadow-[0_0_20px_rgba(59,130,246,0.35)]'
                        : 'text-gray-400 hover:text-white'
                        }`}
                    >
                      <UserCircle2 className="w-4 h-4" /> Buyer / User
                    </button>
                  </div>
                </motion.div>

                {/* Main panel */}
                <div className="grid lg:grid-cols-2 gap-10 items-center">

                  {/* Phone showcase */}
                  <AnimatePresence mode="wait">
                    <motion.div
                      key={tab}
                      initial={{ opacity: 0, x: -30 }}
                      animate={{ opacity: 1, x: 0 }}
                      exit={{ opacity: 0, x: 30 }}
                      transition={{ duration: 0.35, ease: [0.22, 1, 0.36, 1] }}
                      className="flex justify-center gap-4 items-end"
                    >
                      {isOwner ? (
                        <>
                          <div style={{ animation: 'float 7s ease-in-out infinite', transform: 'rotate(-2.5deg)' }}>
                            <Phone src={ownerProfile} alt="Owner Profile" className="w-[175px]" />
                          </div>
                          <div style={{ animation: 'float 6s ease-in-out 0.4s infinite' }}>
                            <Phone src={myProperty} alt="My Properties" className="w-[195px]" />
                          </div>
                          <div style={{ animation: 'float 8s ease-in-out 0.8s infinite', transform: 'rotate(2.5deg)' }}>
                            <Phone src={pushNotif} alt="Push Notification" className="w-[175px]" />
                          </div>
                        </>
                      ) : (
                        <>
                          <div style={{ animation: 'float 7s ease-in-out infinite', transform: 'rotate(-2.5deg)' }}>
                            <Phone src={homeScreen} alt="Home Screen" className="w-[175px]" />
                          </div>
                          <div style={{ animation: 'float 6s ease-in-out 0.4s infinite' }}>
                            <Phone src={propDetail2} alt="Property Detail" className="w-[195px]" />
                          </div>
                          <div style={{ animation: 'float 8s ease-in-out 0.8s infinite', transform: 'rotate(2.5deg)' }}>
                            <Phone src={userProfile} alt="User Profile" className="w-[175px]" />
                          </div>
                        </>
                      )}
                    </motion.div>
                  </AnimatePresence>

                  {/* Feature list */}
                  <AnimatePresence mode="wait">
                    <motion.div
                      key={tab + '_features'}
                      initial={{ opacity: 0, x: 30 }}
                      animate={{ opacity: 1, x: 0 }}
                      exit={{ opacity: 0, x: -30 }}
                      transition={{ duration: 0.35, ease: [0.22, 1, 0.36, 1] }}
                    >
                      <div className="flex items-center gap-3 mb-6">
                        <div className={`w-11 h-11 rounded-2xl flex items-center justify-center ${isOwner ? 'bg-gradient-to-br from-yellow-400 to-orange-500' : 'bg-gradient-to-br from-blue-500 to-blue-700'
                          }`}>
                          {isOwner
                            ? <Crown className="w-5 h-5 text-[#0F2C59]" />
                            : <UserCircle2 className="w-5 h-5 text-white" />}
                        </div>
                        <div>
                          <p className="text-white font-black text-xl">
                            {isOwner ? 'Owner / Admin' : 'Buyer / User'}
                          </p>
                          <p className="text-gray-500 text-xs">
                            {isOwner ? 'Firebase UID registered as owner' : 'Regular Google Sign-in'}
                          </p>
                        </div>
                      </div>

                      <div className="space-y-3">
                        {(isOwner ? ownerFeatures : userFeatures).map((f, i) => (
                          <motion.div
                            key={i}
                            initial={{ opacity: 0, y: 10 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: i * 0.07 }}
                            className={`glass g-card rounded-xl p-4 flex items-start gap-4 border-l-[3px] ${isOwner ? 'border-yellow-400/40' : 'border-blue-400/40'
                              }`}
                          >
                            <span className="text-2xl shrink-0 mt-0.5">{f.icon}</span>
                            <div>
                              <p className="text-white font-semibold text-sm">{f.label}</p>
                              <p className="text-gray-400 text-xs mt-0.5 leading-snug">{f.desc}</p>
                            </div>
                          </motion.div>
                        ))}
                      </div>
                    </motion.div>
                  </AnimatePresence>
                </div>

                {/* ── Comparison Table ── */}
                <motion.div {...fUp(0.15)} className="mt-14 glass g-card rounded-2xl overflow-hidden">
                  <div className="grid grid-cols-3 bg-white/5 px-6 py-3 text-xs font-bold uppercase tracking-widest text-gray-400">
                    <span>Feature</span>
                    <span className="text-center text-yellow-400">👑 Owner</span>
                    <span className="text-center text-blue-400">🧑 Buyer</span>
                  </div>
                  {[
                    ['Browse & Search Properties', true, true],
                    ['Voice AI Search', true, true],
                    ['Map with Property Pins', true, true],
                    ['Chat with Agents', true, true],
                    ['Save to Wishlist', true, true],
                    ['Add / Edit / Delete Listings', true, false],
                    ['Push Notification Broadcast', true, false],
                    ['My Properties Dashboard', true, false],
                    ['Owner Tools in Profile', true, false],
                  ].map(([label, owner, buyer], i) => (
                    <div key={i} className={`grid grid-cols-3 px-6 py-3.5 text-sm border-t border-white/[0.04] ${i % 2 === 0 ? '' : 'bg-white/[0.02]'
                      }`}>
                      <span className="text-gray-300">{label}</span>
                      <span className="text-center">
                        {owner ? <span className="text-green-400 text-base">✓</span> : <span className="text-gray-700 text-base">—</span>}
                      </span>
                      <span className="text-center">
                        {buyer ? <span className="text-green-400 text-base">✓</span> : <span className="text-gray-700 text-base">—</span>}
                      </span>
                    </div>
                  ))}
                </motion.div>

                {/* ── How it works flow ── */}
                <motion.div {...fUp(0.2)} className="mt-10 glass g-card rounded-2xl p-7">
                  <div className="flex items-center gap-2 mb-5">
                    <Lock className="w-4 h-4 text-purple-400" />
                    <p className="text-white font-bold">How Role Separation Works — Under the Hood</p>
                  </div>
                  <div className="flex flex-col sm:flex-row items-center gap-2 text-sm">
                    {[
                      { step: '1', text: 'User signs in with Google', color: 'bg-blue-500/20 border-blue-500/30 text-blue-300' },
                      { step: '→', text: '', color: '' },
                      { step: '2', text: `App reads users/{uid} in Firestore`, color: 'bg-purple-500/20 border-purple-500/30 text-purple-300', code: true },
                      { step: '→', text: '', color: '' },
                      { step: '3', text: `role: "owner" found?`, color: 'bg-yellow-500/20 border-yellow-500/30 text-yellow-300', code: true },
                      { step: '→', text: '', color: '' },
                      { step: '4', text: 'AuthBloc sets isOwner = true → all owner UI unlocks', color: 'bg-green-500/20 border-green-500/30 text-green-300' },
                    ].map((s, i) => (
                      s.step === '→'
                        ? <span key={i} className="text-gray-600 font-bold hidden sm:block">→</span>
                        : (
                          <div key={i} className={`flex-1 min-w-0 border rounded-xl px-3 py-2.5 text-center ${s.color}`}>
                            <span className="font-bold text-xs opacity-60 block mb-0.5">Step {s.step}</span>
                            {s.code
                              ? <code className="text-xs font-mono">{s.text}</code>
                              : <p className="text-xs leading-snug">{s.text}</p>}
                          </div>
                        )
                    ))}
                  </div>
                  <p className="text-gray-600 text-xs mt-4 text-center">
                    No extra app builds. No separate APK. One codebase, two experiences.
                  </p>
                </motion.div>
              </>
            );
          })()}
        </div>
      </section>


      {/* ══════ STATS ════════════════════════════════ */}
      <section className="py-20 px-6 border-y border-white/5">
        <div className="max-w-5xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-5">
          <Stat val="6×" label="Faster to market" icon={Zap} delay={0} />
          <Stat val="100%" label="Source code yours" icon={ShieldCheck} delay={0.1} />
          <Stat val="99.9%" label="Firebase uptime" icon={Globe} delay={0.2} />
          <Stat val="10+" label="Agencies deployed" icon={Building2} delay={0.3} />
        </div>
      </section>

      {/* ══════ PRICING ══════════════════════════════ */}
      <section id="pricing" className="py-28 px-6 relative overflow-hidden">
        <div className="orb w-[600px] h-[600px] bg-blue-900/12 top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2" />
        <div className="max-w-6xl mx-auto relative z-10">
          <div className="text-center mb-14">
            <motion.p {...fUp(0)} className="text-yellow-400 text-[11px] font-bold uppercase tracking-[0.2em] mb-3">
              Pricing
            </motion.p>
            <motion.h2 {...fUp(0.1)} className="text-4xl sm:text-5xl font-black tracking-tight mb-3">
              One License. <span className="gold-text">Fully Yours.</span>
            </motion.h2>
            <motion.p {...fUp(0.2)} className="text-gray-400 text-base">No subscriptions. No royalties.</motion.p>
          </div>
          <div className="grid md:grid-cols-3 gap-6">
            <PricingCard tier="Starter" price="₹6,000" note="/ one-time" delay={0.1}
              features={['Full Flutter Source Code', 'Firebase Integration Guide', 'Custom Splash & App Icon', 'Google Play Ready APK', '3 Months Email Support']} />
            <PricingCard tier="Professional" price="₹8,000" note="/ one-time" hot delay={0.15}
              features={['Everything in Starter', 'Node.js Push Backend', 'Instagram Reel Integration', 'Owner Role System Setup', '6 Months Priority Support', '1-hour Onboarding Call']} />
            <PricingCard tier="Enterprise" price="Custom" delay={0.2}
              features={['Everything in Pro', 'On-demand Features', 'Dedicated Slack Channel', '12-Month Support SLA', 'App Store Help', 'NDA & Source Escrow']} />
          </div>
        </div>
      </section>


      {/* ══════ CTA ══════════════════════════════════ */}
      <section id="contact" className="py-24 px-6 relative overflow-hidden">
        <div className="orb w-[700px] h-[700px] bg-blue-700/12 top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2" />
        <div className="max-w-3xl mx-auto relative z-10 text-center">
          <motion.div {...fUp(0)} className="glass g-card rounded-3xl p-12 sm:p-16">
            <p className="text-yellow-400 text-[11px] font-bold uppercase tracking-[0.2em] mb-4">Ready to Launch?</p>
            <h2 className="text-4xl sm:text-5xl font-black mb-5 tracking-tight leading-tight">
              Your App.<br /><span className="gold-text">Built for Scale.</span>
            </h2>
            <p className="text-gray-400 text-base mb-10 leading-relaxed">
              Book a free 30-minute demo. We walk you through every screen — from the home screen
              to the push notification broadcast — live on a call.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <button className="gold-btn px-10 py-4 rounded-full text-base">
                Book Free Demo <ArrowUpRight className="inline w-5 h-5 ml-1" />
              </button>
              <button
                onClick={() => window.open('https://wa.me/8368804883?text=Hi,%20I%20am%20interested%20in%20the%20Real%20Estate%20App', '_blank')}
                className="outline-btn px-10 py-4 rounded-full text-base"
              >
                💬 WhatsApp Us
              </button>
            </div>
          </motion.div>
        </div>
      </section>

      {/* ══════ FOOTER ═══════════════════════════════ */}
      <footer className="border-t border-white/5 py-8 px-6">
        <div className="max-w-7xl mx-auto flex flex-col sm:flex-row justify-between items-center gap-4 text-xs text-gray-600">
          <div className="flex items-center gap-2">
            <img src={appLogo} alt="Logo" className="w-5 h-5 object-contain" />
            <span className="text-gray-400 font-semibold">Real Estate Application</span>
          </div>
          <p>© {new Date().getFullYear()} Real Estate Application. All rights reserved.</p>
          <div className="flex gap-5">
            <a href="#" className="hover:text-white transition-colors">Privacy</a>
            <a href="#" className="hover:text-white transition-colors">Terms</a>
            <a href="#" className="hover:text-white transition-colors">Contact</a>
          </div>
        </div>
      </footer>

      {/* ══════ VIDEO MODAL ══════════════════════════ */}
      <AnimatePresence>
        {videoOpen && (
          <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
            className="fixed inset-0 z-[100] flex items-center justify-center p-4 md:p-12 bg-black/90 backdrop-blur-sm"
            onClick={() => setVideoOpen(false)}>
            <motion.div
              initial={{ scale: 0.88, opacity: 0 }} animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.88, opacity: 0 }} transition={{ type: 'spring', stiffness: 300, damping: 30 }}
              className="w-full max-w-4xl aspect-video g-card glass rounded-2xl shadow-2xl
                flex flex-col items-center justify-center gap-3 text-gray-500"
              onClick={e => e.stopPropagation()}>
              <Play className="w-14 h-14 text-gray-600" />
              <p className="text-sm">Your product demo video embeds here.</p>
              <button onClick={() => setVideoOpen(false)} className="mt-3 text-xs underline hover:text-white transition-colors">Close</button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

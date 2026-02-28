import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Mic, Play, MessageSquare, Map, Bell, ShieldCheck, ChevronRight,
  X, Star, Zap, Heart, Building2, Users, ArrowUpRight, Menu,
  CheckCheck, Smartphone, Video, Lock, BarChart3, Globe, Crown, UserCircle2,
  Home, Plus, ScrollText, Settings, TrendingUp, Search, Bookmark, Clock, MapPin,
  CheckCircle2, MinusCircle
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
import demoVideo from './assets/img/real-estate-application.mp4';
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
  <div className={`relative shrink-0 ${className || 'w-45 md:w-57.5'}`}>
    <div className="w-full rounded-3xl md:rounded-[38px] border-4 md:border-[6px] border-white/10 overflow-hidden
      shadow-[0_20px_50px_rgba(0,0,0,0.65)] md:shadow-[0_30px_80px_rgba(0,0,0,0.65)]" style={{ background: '#111' }}>
      <img src={src} alt={alt} className="w-full aspect-[9/19.5] object-cover" />
    </div>
    <div className="absolute -bottom-4 md:-bottom-6 left-1/2 -translate-x-1/2 w-[80%] h-10 bg-blue-500/15 blur-2xl rounded-full" />
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
  }, [lightbox, items.length]);

  return (
    <>
      <section className="py-12 md:py-20 relative overflow-hidden">
        <div className="orb w-125 h-125 bg-blue-700/10 top-0 left-1/2 -translate-x-1/2 -translate-y-1/2" />

        {/* Heading */}
        <div className="text-center mb-8 md:mb-12 px-6 relative z-10">
          <motion.p {...fUp(0)} className="text-yellow-400 text-[11px] font-bold uppercase tracking-[0.2em] mb-3">
            Live Previews
          </motion.p>
          <motion.h2 {...fUp(0.1)} className="text-3xl md:text-4xl font-black tracking-tight">
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
            backdrop-blur-md [-webkit-mask-image:linear-gradient(to_right,black,transparent)] mask-[linear-gradient(to_right,black,transparent)]" />
          <div className="pointer-events-none absolute inset-y-0 right-0 w-28 z-10
            backdrop-blur-md [-webkit-mask-image:linear-gradient(to_left,black,transparent)] mask-[linear-gradient(to_left,black,transparent)]" />

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
                  className="w-27.5 md:w-37 rounded-3xl md:rounded-[30px] border-[3px] md:border-4 border-white/10 overflow-hidden
                  shadow-[0_12px_35px_rgba(0,0,0,0.5)] md:shadow-[0_16px_45px_rgba(0,0,0,0.5)] transition-all duration-300
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
            className="fixed inset-0 z-200 flex items-center justify-center bg-black/92 backdrop-blur-md"
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
                  className="w-60 md:w-70 rounded-4xl md:rounded-[40px] border-[5px] md:border-[6px] border-white/15
                  overflow-hidden shadow-[0_30px_70px_rgba(0,0,0,0.8)] md:shadow-[0_40px_100px_rgba(0,0,0,0.8)]"
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
/* ── Feature Row accent palette ──────────────── */
const FEAT_ACCENT = {
  amber: {
    pill:     'bg-amber-400/10 text-amber-300 border-amber-400/25',
    badge:    'bg-amber-400/10 text-amber-400 border-amber-400/25',
    card:     'border-l-amber-400/50 hover:border-l-amber-300',
    glow:     'bg-amber-400/18',
    stepClr:  'text-amber-400/[0.045]',
  },
  blue: {
    pill:     'bg-blue-400/10 text-blue-300 border-blue-400/25',
    badge:    'bg-blue-400/10 text-blue-400 border-blue-400/25',
    card:     'border-l-blue-400/50 hover:border-l-blue-300',
    glow:     'bg-blue-500/18',
    stepClr:  'text-blue-400/[0.045]',
  },
  purple: {
    pill:     'bg-purple-400/10 text-purple-300 border-purple-400/25',
    badge:    'bg-purple-400/10 text-purple-400 border-purple-400/25',
    card:     'border-l-purple-400/50 hover:border-l-purple-300',
    glow:     'bg-purple-500/15',
    stepClr:  'text-purple-400/[0.045]',
  },
};

const FeatureRow = ({ tag, tagIcon, highlight, heading, sub, bullets, img, alt, reverse = false, delay = 0, step, accent = 'amber' }) => {
  const a = FEAT_ACCENT[accent];
  return (
    <div className={`relative flex flex-col ${reverse ? 'lg:flex-row-reverse' : 'lg:flex-row'} items-center gap-14 lg:gap-20`}>

      {/* Big faded step number — decorative background */}
      <span
        aria-hidden
        className={`pointer-events-none select-none absolute hidden lg:block font-black leading-none ${a.stepClr}
          ${reverse ? '-right-2 lg:right-0' : '-left-2 lg:left-0'} -top-10`}
        style={{ fontSize: 'clamp(130px, 15vw, 210px)' }}
      >
        {step}
      </span>

      {/* ── Text column ── */}
      <motion.div {...fUp(delay)} className="flex-1 relative z-10">
        {/* Tag + highlight pill row */}
        <div className="flex flex-wrap items-center gap-2.5 mb-5">
          <span className={`inline-flex items-center gap-2 text-[11px] font-bold uppercase tracking-[0.17em]
            border rounded-full px-3.5 py-1.5 ${a.pill}`}>
            {tagIcon && <span className="text-sm leading-none">{tagIcon}</span>}
            {tag}
          </span>
          {highlight && (
            <span className={`inline-flex items-center gap-1.5 text-[10px] font-bold uppercase tracking-wider
              border rounded-full px-2.5 py-1 ${a.badge}`}>
              {highlight}
            </span>
          )}
        </div>

        <h3
          className="text-3xl md:text-4xl font-black tracking-tight mb-4 text-white leading-[1.12]"
          dangerouslySetInnerHTML={{ __html: heading }}
        />
        <p className="text-gray-400 mb-8 leading-relaxed text-[15px] max-w-lg">{sub}</p>

        {/* Bullets as 2-col glass cards */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          {bullets.map((b, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 8 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: delay + 0.1 + i * 0.07, duration: 0.45 }}
              className={`glass g-card rounded-xl p-3.5 flex items-start gap-3 border-l-[3px]
                transition-colors duration-200 ${a.card}`}
            >
              <CheckCheck className="w-4 h-4 text-green-400 shrink-0 mt-0.5" />
              <span className="text-[13px] text-gray-300 leading-snug">{b}</span>
            </motion.div>
          ))}
        </div>
      </motion.div>

      {/* ── Phone + colored glow ── */}
      <motion.div
        {...fUp(delay + 0.12)}
        className="shrink-0 flex justify-center relative w-full lg:w-auto mt-12 lg:mt-0"
      >
        {/* Glow blob behind phone */}
        <div
          className={`absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2
            w-55 h-75 rounded-full blur-[70px] opacity-70 ${a.glow}`}
        />
        <Phone
          src={img} alt={alt}
          className="w-57.5 sm:w-65 md:w-62.5 lg:w-67.5 phone-float relative z-10
            drop-shadow-[0_25px_60px_rgba(0,0,0,0.65)]"
        />
      </motion.div>
    </div>
  );
};

/* ── Role-Based Features Component ─────────────── */
const RoleBasedFeatures = () => {
  const [tab, setTab] = React.useState('owner');
  const isOwner = tab === 'owner';

  const ownerFeatures = [
    { icon: <Home className="w-5 h-5 text-yellow-400" />, label: 'My Properties', desc: 'Manage all listings with edit & delete controls' },
    { icon: <Plus className="w-5 h-5 text-yellow-400" />, label: 'Add New Property', desc: 'Full form: image, price, type, amenities, location' },
    { icon: <ScrollText className="w-5 h-5 text-yellow-400" />, label: 'Batch Push Broadcast', desc: 'Send rich notifications with images to all users in batches' },
    { icon: <Settings className="w-5 h-5 text-yellow-400" />, label: 'Owner Tools Panel', desc: 'Exclusive section visible only in admin profile' },
    { icon: <TrendingUp className="w-5 h-5 text-yellow-400" />, label: 'Listing Insights', desc: 'See how many users saved or viewed your properties' },
  ];
  const userFeatures = [
    { icon: <Search className="w-5 h-5 text-blue-400" />, label: 'Browse Properties', desc: 'Discover best offers and nearest properties on home' },
    { icon: <Bookmark className="w-5 h-5 text-blue-400" />, label: 'Save Properties', desc: 'Wishlist any property and revisit anytime' },
    { icon: <MessageSquare className="w-5 h-5 text-blue-400" />, label: 'Chat with Agent', desc: 'Open WhatsApp-style real-time chat from property detail' },
    { icon: <Clock className="w-5 h-5 text-blue-400" />, label: 'Recently Viewed', desc: 'Instantly revisit properties you\'ve explored' },
    { icon: <MapPin className="w-5 h-5 text-blue-400" />, label: 'Explore on Map', desc: 'Tap markers to preview property cards on the map' },
  ];

  return (
    <>
      {/* Tab pills */}
      <motion.div {...fUp(0.15)} className="flex justify-center mb-10">
        <div className="glass g-card inline-flex rounded-2xl p-1.5 gap-1">
          <button
            onClick={() => setTab('owner')}
            className={`flex items-center gap-2 px-6 py-2.5 rounded-xl text-sm font-bold transition-all duration-300 ${isOwner
              ? 'bg-linear-to-r from-yellow-400 to-orange-500 text-[#0F2C59] shadow-[0_0_20px_rgba(255,215,0,0.35)]'
              : 'text-gray-400 hover:text-white'
              }`}
          >
            <Crown className="w-4 h-4" /> Owner / Admin
          </button>
          <button
            onClick={() => setTab('buyer')}
            className={`flex items-center gap-2 px-6 py-2.5 rounded-xl text-sm font-bold transition-all duration-300 ${!isOwner
              ? 'bg-linear-to-r from-blue-500 to-blue-700 text-white shadow-[0_0_20px_rgba(59,130,246,0.35)]'
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
            className="relative flex justify-center items-end mt-8 lg:mt-0 h-95 md:h-auto md:-space-x-6"
          >
            {isOwner ? (
              <>
                <div className="absolute -left-2.5 sm:left-12 md:static z-0 opacity-50 md:opacity-100 rotate-[-4deg]">
                  <div style={{ animation: 'float 7s ease-in-out infinite' }}>
                    <Phone src={ownerProfile} alt="Owner Profile" className="w-32.5 md:w-43.75" />
                  </div>
                </div>
                <div style={{ animation: 'float 6s ease-in-out 0.4s infinite' }}
                  className="relative z-10 drop-shadow-[0_0_40px_rgba(0,0,0,0.8)]">
                  <Phone src={myProperty} alt="My Properties" className="w-45 sm:w-50 md:w-48.75" />
                </div>
                <div className="absolute -right-2.5 sm:right-12 md:static z-0 opacity-50 md:opacity-100 rotate-[4deg]">
                  <div style={{ animation: 'float 8s ease-in-out 0.8s infinite' }}>
                    <Phone src={pushNotif} alt="Push Notification" className="w-32.5 md:w-43.75" />
                  </div>
                </div>
              </>
            ) : (
              <>
                <div className="absolute -left-2.5 sm:left-12 md:static z-0 opacity-50 md:opacity-100 rotate-[-4deg]">
                  <div style={{ animation: 'float 7s ease-in-out infinite' }}>
                    <Phone src={homeScreen} alt="Home Screen" className="w-32.5 md:w-43.75" />
                  </div>
                </div>
                <div style={{ animation: 'float 6s ease-in-out 0.4s infinite' }}
                  className="relative z-10 drop-shadow-[0_0_40px_rgba(0,0,0,0.8)]">
                  <Phone src={propDetail2} alt="Property Detail" className="w-45 sm:w-50 md:w-48.75" />
                </div>
                <div className="absolute -right-2.5 sm:right-12 md:static z-0 opacity-50 md:opacity-100 rotate-[4deg]">
                  <div style={{ animation: 'float 8s ease-in-out 0.8s infinite' }}>
                    <Phone src={userProfile} alt="User Profile" className="w-32.5 md:w-43.75" />
                  </div>
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
              <div className={`w-11 h-11 rounded-2xl flex items-center justify-center ${isOwner ? 'bg-linear-to-br from-yellow-400 to-orange-500' : 'bg-linear-to-br from-blue-500 to-blue-700'
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

            <div className="space-y-2.5">
              {(isOwner ? ownerFeatures : userFeatures).map((f, i) => (
                <motion.div
                  key={i}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: i * 0.07 }}
                  className={`group relative flex items-center gap-4 rounded-2xl px-4 py-3.5 border transition-all duration-200 cursor-default
                    ${isOwner
                      ? 'border-yellow-400/10 bg-yellow-400/[0.03] hover:bg-yellow-400/[0.07] hover:border-yellow-400/25'
                      : 'border-blue-400/10 bg-blue-400/[0.03] hover:bg-blue-400/[0.07] hover:border-blue-400/25'}`}
                >
                  {/* Step number */}
                  <span className={`shrink-0 w-5 text-center text-[10px] font-black tabular-nums
                    ${isOwner ? 'text-yellow-400/40' : 'text-blue-400/40'}`}>
                    {String(i + 1).padStart(2, '0')}
                  </span>
                  {/* Icon badge */}
                  <div className={`shrink-0 w-10 h-10 rounded-xl flex items-center justify-center border
                    ${isOwner
                      ? 'bg-yellow-400/10 border-yellow-400/20 shadow-[0_0_14px_rgba(250,204,21,0.12)] group-hover:shadow-[0_0_20px_rgba(250,204,21,0.2)]'
                      : 'bg-blue-400/10 border-blue-400/20 shadow-[0_0_14px_rgba(96,165,250,0.12)] group-hover:shadow-[0_0_20px_rgba(96,165,250,0.2)]'}
                    transition-shadow duration-200`}>
                    {f.icon}
                  </div>
                  {/* Text */}
                  <div className="flex-1 min-w-0">
                    <p className="text-white font-bold text-sm leading-tight">{f.label}</p>
                    <p className="text-gray-500 text-xs mt-0.5 leading-snug">{f.desc}</p>
                  </div>
                  {/* Arrow */}
                  <ChevronRight className={`shrink-0 w-4 h-4 opacity-0 group-hover:opacity-100 transition-opacity duration-200
                    ${isOwner ? 'text-yellow-400' : 'text-blue-400'}`} />
                </motion.div>
              ))}
            </div>
          </motion.div>
        </AnimatePresence>
      </div>

      {/* ── Comparison Table ── */}
      <motion.div {...fUp(0.15)} className="mt-14 rounded-2xl overflow-hidden w-full border border-white/8 shadow-xl shadow-black/30">
        {/* Header */}
        <div className="grid grid-cols-3 px-5 py-4">
          <span className="text-xs font-bold uppercase tracking-widest text-gray-500">Feature</span>
          <span className="flex flex-col items-center gap-1">
            <span className="w-8 h-8 rounded-xl bg-yellow-400/15 border border-yellow-400/25 flex items-center justify-center">
              <Crown className="w-4 h-4 text-yellow-400" />
            </span>
            <span className="text-[10px] font-black uppercase tracking-widest text-yellow-400">Owner</span>
          </span>
          <span className="flex flex-col items-center gap-1">
            <span className="w-8 h-8 rounded-xl bg-blue-400/15 border border-blue-400/25 flex items-center justify-center">
              <UserCircle2 className="w-4 h-4 text-blue-400" />
            </span>
            <span className="text-[10px] font-black uppercase tracking-widest text-blue-400">Buyer</span>
          </span>
        </div>
        {/* Rows */}
        <div className="divide-y divide-white/5">
          {[
            { feature: 'Add / Edit / Delete Properties', owner: true, buyer: false },
            { feature: 'Send Push Notifications', owner: true, buyer: false },
            { feature: 'Admin Tools Panel', owner: true, buyer: false },
            { feature: 'Property Insights & Analytics', owner: true, buyer: false },
            { feature: 'Browse All Properties', owner: true, buyer: true },
            { feature: 'Save / Wishlist Properties', owner: true, buyer: true },
            { feature: 'View on Interactive Map', owner: true, buyer: true },
            { feature: 'Live Chat with Agent', owner: true, buyer: true },
            { feature: 'Story Video Player', owner: true, buyer: true },
            { feature: 'Voice AI Search', owner: true, buyer: true },
          ].map(({ feature, owner, buyer }, idx) => (
            <div key={idx} className="grid grid-cols-3 px-5 py-3 items-center hover:bg-white/[0.015] transition-colors">
              <span className="text-xs text-gray-400 font-medium">{feature}</span>
              <span className="flex justify-center">
                {owner ? (
                  <CheckCircle2 className="w-4.5 h-4.5 text-yellow-400" />
                ) : (
                  <MinusCircle className="w-4.5 h-4.5 text-gray-600" />
                )}
              </span>
              <span className="flex justify-center">
                {buyer ? (
                  <CheckCircle2 className="w-4.5 h-4.5 text-blue-400" />
                ) : (
                  <MinusCircle className="w-4.5 h-4.5 text-gray-600" />
                )}
              </span>
            </div>
          ))}
        </div>
        <div className="px-5 py-4 bg-white/[0.015]">
          <p className="text-gray-600 text-xs text-center">
            No extra app builds. No separate APK. One codebase, two experiences.
          </p>
        </div>
      </motion.div>
    </>
  );
};

/* ── Stat ─────────────────────────────────────── */
// eslint-disable-next-line no-unused-vars
const Stat = ({ val, label, icon: IconComponent, delay }) => (
  <motion.div {...fUp(delay)} className="glass g-card rounded-2xl p-6 flex flex-col gap-1 items-center text-center">
    <div className="w-10 h-10 rounded-full bg-yellow-400/10 flex items-center justify-center mb-2">
      <IconComponent className="w-5 h-5 text-yellow-400" />
    </div>
    <p className="text-4xl font-black stat-n gold-text">{val}</p>
    <p className="text-gray-400 text-xs font-medium">{label}</p>
  </motion.div>
);

/* ── Pricing ──────────────────────────────────── */
const PricingCard = ({ tier, price, note, features, hot, delay, whatsappMsg }) => (
  <motion.div {...fUp(delay)}
    className={`g-card rounded-2xl p-8 flex flex-col gap-5 relative overflow-hidden
      ${hot ? 'bg-linear-to-b from-[#132d5e]/60 to-[#0a1628]/90' : 'glass'}`}>
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
    <button
      onClick={() => window.open(`https://wa.me/8368804883?text=${encodeURIComponent(whatsappMsg)}`, '_blank')}
      className={`w-full py-3.5 rounded-full text-sm font-bold ${hot ? 'gold-btn' : 'outline-btn'}`}>
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
      className="bg-[#04091a] min-h-screen text-white w-full max-w-[100vw] overflow-x-hidden select-none"
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
            <button onClick={() => window.open('https://wa.me/8368804883?text=Hi,%20I%20am%20interested%20in%20the%20Real%20Estate%20App', '_blank')} className="outline-btn text-sm px-5 py-2.5 rounded-full">Contact Sales</button>
            <button onClick={() => window.open('https://wa.me/8368804883?text=Hi,%20I%20am%20interested%20in%20the%20Real%20Estate%20App', '_blank')} className="gold-btn text-sm px-5 py-2.5 rounded-full">Get the App →</button>
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
              <button onClick={() => window.open('https://wa.me/8368804883?text=Hi,%20I%20am%20interested%20in%20the%20Real%20Estate%20App', '_blank')} className="gold-btn text-sm px-6 py-3 rounded-full mt-2">Get the App →</button>
            </motion.div>
          )}
        </AnimatePresence>
      </header>

      {/* ══════ HERO ═════════════════════════════════ */}
      <section className="relative min-h-screen flex items-center justify-center pt-24 md:pt-32 pb-16 px-6 overflow-hidden">
        <div className="orb w-175 h-175 bg-blue-700/15 -top-48 -left-56" style={{ animation: 'drift 12s ease-in-out infinite' }} />
        <div className="orb w-125 h-125 bg-yellow-400/6  bottom-0 -right-30" style={{ animation: 'drift 9s ease-in-out infinite alternate' }} />

        <div className="max-w-7xl mx-auto grid lg:grid-cols-2 items-center gap-16 relative z-10">
          {/* Text */}
          <motion.div initial={{ opacity: 0, x: -40 }} animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.9, ease: [0.22, 1, 0.36, 1] }}>
            <div className="inline-flex items-center gap-2 glass border border-yellow-500/20 rounded-full
              px-3 md:px-4 py-1.5 text-[9px] md:text-[11px] font-bold uppercase tracking-[0.14em] text-yellow-400 mb-7">
              <Zap className="w-3 h-3" /> White-Label Flutter Real Estate App
            </div>
            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-black leading-[1.1] md:leading-[1.06] tracking-[-0.02em] mb-6">
              Your Own Branded <br />
              <span className="shine-text">Property App</span><br />
              in Days.
            </h1>
            <p className="text-gray-400 text-base md:text-lg leading-relaxed mb-10 max-w-lg">
              Skip 6 months of development. Get a production-ready Flutter real estate app —
              voice AI search, Instagram Reels, live chat, push notifications — and brand it as yours.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 mb-10">
              <button onClick={() => window.open('https://wa.me/8368804883?text=Hi,%20I%20want%20to%20get%20the%20Real%20Estate%20App%20source%20code', '_blank')} className="gold-btn px-9 py-4 rounded-full text-base flex items-center justify-center gap-2">
                Get Source Code <ArrowUpRight className="w-5 h-5" />
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
              <span className="flex items-center gap-1.5"><Users className="w-4 h-4 text-blue-400" /> Launch-Ready</span>
              <span className="flex items-center gap-1.5"><Heart className="w-4 h-4 text-red-400" fill="#f87171" /> 4.9★ Rated</span>
              <span className="flex items-center gap-1.5"><Smartphone className="w-4 h-4 text-purple-400" /> Android Ready</span>
            </div>
          </motion.div>

          {/* 3-Phone cluster */}
          <motion.div initial={{ opacity: 0, y: 40 }} animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.9, delay: 0.15, ease: [0.22, 1, 0.36, 1] }}
            className="relative flex items-end justify-center mt-12 lg:mt-0 h-100 md:h-auto md:-space-x-6">

            <div className="absolute -left-5 sm:left-10 md:static md:-mb-5 z-0 opacity-50 md:opacity-100 rotate-[-5deg]">
              <div style={{ animation: 'float 7s ease-in-out infinite' }}>
                <Phone src={homeScreen} alt="Home Screen" className="w-35 md:w-45" />
              </div>
            </div>

            <div style={{ animation: 'float 6s ease-in-out .5s infinite' }}
              className="relative z-10 drop-shadow-[0_0_40px_rgba(0,0,0,0.8)]">
              <Phone src={mapScreen} alt="Map Screen" className="w-50 sm:w-55 md:w-52.5" />
            </div>

            <div className="absolute -right-5 sm:right-10 md:static md:-mb-5 z-0 opacity-50 md:opacity-100 rotate-[5deg]">
              <div style={{ animation: 'float 8s ease-in-out 1s infinite' }}>
                <Phone src={propDetail1} alt="Property Detail" className="w-35 md:w-45" />
              </div>
            </div>

          </motion.div>
        </div>
        <div className="pointer-events-none absolute bottom-0 left-0 right-0 h-32 z-10
          backdrop-blur-md [-webkit-mask-image:linear-gradient(to_top,black,transparent)] mask-[linear-gradient(to_top,black,transparent)]" />
      </section>

      {/* ── TICKER ──────────────────────────────────── */}
      <Ticker />

      {/* ══════ SCREEN CAROUSEL ══════════════════════ */}
      <ScreenCarousel images={{ homeScreen, mapScreen, propDetail1, propDetail2, ownerProfile, userProfile, myProperty, addProp1, pushNotif }} />

      {/* ══════ FEATURES SHOWCASE ════════════════════ */}
      <section id="features" className="py-16 md:py-28 px-6 relative overflow-hidden">
        <div className="orb w-150 h-150 bg-blue-800/8 -top-20 -right-45" />
        <div className="orb w-125 h-125 bg-amber-400/4 bottom-0 -left-45" />

        <div className="max-w-7xl mx-auto relative z-10">

          {/* ── Section header ── */}
          <div className="text-center mb-16 md:mb-24">
            <motion.p {...fUp(0)} className="text-yellow-400 text-[11px] font-bold uppercase tracking-[0.2em] mb-3">
              Feature Showcase
            </motion.p>
            <motion.h2 {...fUp(0.1)} className="text-3xl md:text-4xl lg:text-5xl font-black tracking-tight mb-4">
              Real Screenshots. <span className="gold-text">Real Features.</span>
            </motion.h2>
            <motion.p {...fUp(0.15)} className="text-gray-500 text-sm max-w-lg mx-auto mb-8 leading-relaxed">
              Every pixel purposeful — built for real buyers, agents, and property owners.
            </motion.p>
            {/* Category pills */}
            <motion.div {...fUp(0.2)} className="flex flex-wrap justify-center gap-2.5">
              {[
                { icon: '🏠', label: 'Home Screen', color: 'bg-amber-400/8 border-amber-400/20 text-amber-300' },
                { icon: '🗺️', label: 'Map View',    color: 'bg-blue-400/8   border-blue-400/20   text-blue-300' },
                { icon: '🏡', label: 'Property Detail', color: 'bg-purple-400/8 border-purple-400/20 text-purple-300' },
              ].map(({ icon, label, color }) => (
                <span key={label} className={`inline-flex items-center gap-2 text-[11px] font-semibold
                  border rounded-full px-4 py-1.5 ${color}`}>
                  <span>{icon}</span>{label}
                </span>
              ))}
            </motion.div>
          </div>

          {/* ── Feature rows with dividers ── */}
          <div className="space-y-24 md:space-y-36">

            {/* 01 — Home Screen */}
            <FeatureRow
              step="01" accent="amber"
              tag="Home Screen" tagIcon="🏠" highlight="★ Most Loved"
              heading="Smart Discovery,<br/>Voice-Powered Search"
              sub="Users land on a beautiful property feed with Best Offers and Nearest Properties. A rotating animated search bar hints at popular categories — one mic tap activates AI voice search with a live waveform animation."
              bullets={[
                'Rotating bar: "Apartment" → "Villa" → "Office"',
                'Voice mic with live waveform visualizer',
                'Location-aware header with GPS address',
                'Draggable Instagram Reel story player',
              ]}
              img={homeScreen} alt="Home Screen"
              delay={0}
            />

            {/* Divider */}
            <div aria-hidden className="flex items-center gap-4">
              <div className="h-px flex-1 bg-linear-to-r from-transparent via-white/10 to-transparent" />
              <span className="text-white/10 text-xs font-bold tracking-widest uppercase">✦</span>
              <div className="h-px flex-1 bg-linear-to-r from-transparent via-white/10 to-transparent" />
            </div>

            {/* 02 — Map */}
            <FeatureRow
              step="02" accent="blue"
              tag="Map Screen" tagIcon="🗺️" highlight="Live Pins"
              heading="Every Property,<br/>Pinned on the Map"
              sub="Buyers explore a fully interactive map with property image-pins. Tap any pin to see a quick card with price, rating, and distance. The bottom search bar supports voice-dictated or typed map searches in real time."
              bullets={[
                'Property photo-pins on an interactive OSM map',
                'Tap pin → instant property preview card',
                'GPS zoom + current location awareness',
                'Voice search overlaid directly on map',
              ]}
              img={mapScreen} alt="Map Screen"
              reverse delay={0.05}
            />

            {/* Divider */}
            <div aria-hidden className="flex items-center gap-4">
              <div className="h-px flex-1 bg-linear-to-r from-transparent via-white/10 to-transparent" />
              <span className="text-white/10 text-xs font-bold tracking-widest uppercase">✦</span>
              <div className="h-px flex-1 bg-linear-to-r from-transparent via-white/10 to-transparent" />
            </div>

            {/* 03 — Property Detail */}
            <FeatureRow
              step="03" accent="purple"
              tag="Property Detail" tagIcon="🏡" highlight="1-Tap Connect"
              heading="Rich Details,<br/>One Tap to Connect"
              sub="A clean, image-first layout with swipeable gallery, full amenities grid, and listing agent info. A sticky bottom bar puts Rent Now and Chat with Agent always within reach."
              bullets={[
                'Full-width hero image with favourite button',
                'Swipeable photo gallery strip',
                'Amenities grid: Beds, Baths, Sqft, Kitchen',
                'Chat with Agent → opens real-time chat',
              ]}
              img={propDetail1} alt="Property Detail"
              delay={0.05}
            />
          </div>
        </div>
      </section>

      {/* ══════ OWNER vs USER ═════════════════════════ */}
      <section id="owner" className="py-16 md:py-28 px-6 relative overflow-hidden">
        <div className="orb w-175 h-175 bg-yellow-400/4 top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2" />
        <div className="orb w-100 h-100 bg-blue-700/10 top-0 -right-25" />

        <div className="max-w-7xl mx-auto relative z-10">

          {/* ── Heading ── */}
          <div className="text-center mb-10 md:mb-14">
            <motion.p {...fUp(0)} className="text-yellow-400 text-[11px] font-bold uppercase tracking-[0.2em] mb-3">
              Role-Based Access Control
            </motion.p>
            <motion.h2 {...fUp(0.1)} className="text-3xl md:text-4xl lg:text-5xl font-black tracking-tight mb-4">
              Owner vs Buyer — <span className="gold-text">Unified Architecture.</span>
            </motion.h2>
            <motion.p {...fUp(0.2)} className="text-gray-400 max-w-2xl mx-auto text-base leading-relaxed">
              No need to manage a separate admin dashboard. Simply assign owner privileges via Firebase,
              and the application dynamically unlocks a comprehensive suite of management tools.
            </motion.p>
          </div>

          {/* ── Tab selector ── */}
          <RoleBasedFeatures />
        </div>
      </section>


      {/* ══════ STATS ════════════════════════════════ */}
      <section className="py-12 md:py-20 px-6 border-y border-white/5">
        <div className="max-w-5xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-5">
          <Stat val="6��" label="Faster to market" icon={Zap} delay={0} />
          <Stat val="100%" label="Source code yours" icon={ShieldCheck} delay={0.1} />
          <Stat val="99.9%" label="Firebase uptime" icon={Globe} delay={0.2} />
          <Stat val="2-in-1" label="Apps, one codebase" icon={Building2} delay={0.3} />
        </div>
      </section>

      {/* ═══��══ PRICING ════���═════════════════════════ */}
      <section id="pricing" className="py-16 md:py-28 px-6 relative overflow-hidden">
        <div className="orb w-150 h-150 bg-blue-900/12 top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2" />
        <div className="max-w-6xl mx-auto relative z-10">
          <div className="text-center mb-10 md:mb-14">
            <motion.p {...fUp(0)} className="text-yellow-400 text-[11px] font-bold uppercase tracking-[0.2em] mb-3">
              Pricing
            </motion.p>
            <motion.h2 {...fUp(0.1)} className="text-3xl md:text-4xl lg:text-5xl font-black tracking-tight mb-3">
              One License. <span className="gold-text">Fully Yours.</span>
            </motion.h2>
            <motion.p {...fUp(0.2)} className="text-gray-400 text-base">No subscriptions. No royalties.</motion.p>
          </div>
          <div className="grid md:grid-cols-3 gap-6">
            <PricingCard tier="Starter" price="₹10,000" note="/ one-time" delay={0.1}
              whatsappMsg="Hi, I am interested in the Starter plan (₹10,000) for the Real Estate App."
              features={['Full Flutter Source Code', 'Firebase Integration Guide', 'Custom Splash & App Icon', 'Google Play Ready APK', '3 Months Email Support']} />
            <PricingCard tier="Professional" price="₹12,000" note="/ one-time" hot delay={0.15}
              whatsappMsg="Hi, I want to get started with the Professional plan (₹12,000) for the Real Estate App."
              features={['Everything in Starter', 'Node.js Push Backend', 'Instagram Reel Integration', 'Owner Role System Setup', '6 Months Priority Support', '1-hour Onboarding Call']} />
            <PricingCard tier="Enterprise" price="Custom" delay={0.2}
              whatsappMsg="Hi, I want to discuss the Enterprise plan for the Real Estate App. Can we schedule a call?"
              features={['Everything in Pro', 'On-demand Features', 'Dedicated Slack Channel', '12-Month Support SLA', 'App Store Help', 'NDA & Source Escrow']} />
          </div>
        </div>
      </section>


      {/* ══════ CTA ══════════════════════════════════ */}
      <section id="contact" className="py-16 md:py-24 px-6 relative overflow-hidden">
        <div className="orb w-175 h-175 bg-blue-700/12 top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2" />
        <div className="max-w-3xl mx-auto relative z-10 text-center">
          <motion.div {...fUp(0)} className="glass g-card rounded-4xl md:rounded-[3rem] p-8 md:p-12 lg:p-16">
            <p className="text-yellow-400 text-[11px] font-bold uppercase tracking-[0.2em] mb-4">Let's Connect</p>
            <h2 className="text-3xl md:text-4xl lg:text-5xl font-black mb-5 tracking-tight leading-tight">
              Book a Free<br /><span className="gold-text">30-Min Meeting.</span>
            </h2>
            <p className="text-gray-400 text-base mb-10 leading-relaxed">
              Let's jump on a quick call. We'll walk you through the full app live —
              answer your questions and get you started the same day.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <button
                onClick={() => window.open('https://wa.me/8368804883?text=Hi,%20I%20want%20to%20schedule%20a%20meeting%20to%20discuss%20the%20Real%20Estate%20App', '_blank')}
                className="gold-btn px-10 py-4 rounded-full text-base">
                Schedule a Meeting <ArrowUpRight className="inline w-5 h-5 ml-1" />
              </button>
              <button
                onClick={() => window.open('https://wa.me/8368804883?text=Hi,%20I%20want%20to%20schedule%20a%20meeting%20to%20discuss%20the%20Real%20Estate%20App', '_blank')}
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
            className="fixed inset-0 z-100 flex items-center justify-center p-4 md:p-12 bg-black/90 backdrop-blur-sm"
            onClick={() => setVideoOpen(false)}>
            <motion.div
              initial={{ scale: 0.88, opacity: 0 }} animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.88, opacity: 0 }} transition={{ type: 'spring', stiffness: 300, damping: 30 }}
              className="w-full max-w-4xl aspect-video g-card glass rounded-2xl shadow-2xl overflow-hidden relative"
              onClick={e => e.stopPropagation()}>
              <video
                src={demoVideo}
                controls
                autoPlay
                className="w-full h-full object-contain rounded-2xl"
              />
              <button onClick={() => setVideoOpen(false)} className="absolute top-3 right-3 z-10 text-xs bg-black/60 hover:bg-black/80 text-white px-3 py-1.5 rounded-full transition-colors">✕ Close</button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

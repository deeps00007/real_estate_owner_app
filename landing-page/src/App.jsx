import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Mic, Play, MessageSquare, Map, Bell, ShieldCheck, ChevronRight,
  X, Star, Zap, Heart, Building2, Users, ArrowUpRight, Menu,
  CheckCheck, Smartphone, Video, Lock, BarChart3, Globe
} from 'lucide-react';

/* ──────────────────────────────────────────────────
   Helpers
────────────────────────────────────────────────── */
const fUp = (d = 0) => ({
  initial: { opacity: 0, y: 36 },
  whileInView: { opacity: 1, y: 0 },
  viewport: { once: true },
  transition: { duration: 0.65, delay: d, ease: [0.22, 1, 0.36, 1] },
});

/* ──────────────────────────────────────────────────
   Ticker Strip
────────────────────────────────────────────────── */
const TAGS = ['Voice AI Search', 'Story Video Player', 'Live Agent Chat', 'Smart Map', 'Rich Push Alerts', 'Role-Based Access', 'White-Label Ready', 'Firebase Powered'];
const Ticker = () => (
  <div className="overflow-hidden py-4 border-y border-white/5 bg-[#06101f]">
    <div className="ticker-track flex gap-14 whitespace-nowrap w-max">
      {[...TAGS, ...TAGS].map((t, i) => (
        <span key={i} className="text-xs font-bold uppercase tracking-[0.18em] text-gray-500 flex items-center gap-3">
          <span className="text-yellow-400 text-base">✦</span>{t}
        </span>
      ))}
    </div>
  </div>
);

/* ──────────────────────────────────────────────────
   Feature Card
────────────────────────────────────────────────── */
const FeatureCard = ({ icon: Icon, grad, title, desc, delay }) => (
  <motion.div {...fUp(delay)}
    whileHover={{ y: -4, transition: { duration: 0.25 } }}
    className="g-card glass p-7 rounded-2xl flex flex-col gap-4 group"
  >
    <div className={`icon-ring w-12 h-12 rounded-2xl ${grad} flex items-center justify-center`}>
      <Icon className="w-6 h-6 text-white" strokeWidth={1.8} />
    </div>
    <div>
      <h3 className="text-base font-bold text-white mb-1.5 tracking-tight">{title}</h3>
      <p className="text-gray-400 text-sm leading-relaxed">{desc}</p>
    </div>
    <span className="text-xs text-yellow-400/70 font-semibold flex items-center gap-1 
      opacity-0 group-hover:opacity-100 transition-opacity duration-300">
      Learn more <ArrowUpRight className="w-3 h-3" />
    </span>
  </motion.div>
);

/* ──────────────────────────────────────────────────
   Stat Box
────────────────────────────────────────────────── */
const Stat = ({ val, label, icon: Icon, delay }) => (
  <motion.div {...fUp(delay)} className="glass g-card rounded-2xl p-6 flex flex-col gap-2 text-center">
    <div className="w-10 h-10 rounded-full bg-yellow-400/10 flex items-center justify-center mx-auto mb-1">
      <Icon className="w-5 h-5 text-yellow-400" />
    </div>
    <p className="text-4xl font-black stat-n gold-text">{val}</p>
    <p className="text-gray-400 text-xs leading-snug font-medium">{label}</p>
  </motion.div>
);

/* ──────────────────────────────────────────────────
   Pricing Card
────────────────────────────────────────────────── */
const PricingCard = ({ tier, price, note, features, hot, delay }) => (
  <motion.div {...fUp(delay)}
    className={`g-card rounded-2xl p-8 flex flex-col gap-6 relative overflow-hidden
      ${hot ? 'bg-gradient-to-b from-[#132d5e]/60 to-[#0a1628]/80' : 'glass'}`}
  >
    {hot && (
      <>
        <div className="absolute top-0 right-0 w-32 h-32 bg-yellow-500/10 rounded-full blur-2xl" />
        <span className="absolute top-4 right-4 text-[10px] font-black uppercase tracking-widest 
          bg-yellow-400 text-[#0F2C59] px-3 py-1 rounded-full">⭐ Best Value</span>
      </>
    )}
    <div>
      <p className="text-gray-400 text-sm font-medium mb-2">{tier}</p>
      <div className="flex items-end gap-2">
        <span className="text-4xl font-black text-white">{price}</span>
        {note && <span className="text-gray-500 text-sm mb-1">{note}</span>}
      </div>
    </div>
    <ul className="flex flex-col gap-3 flex-1">
      {features.map((f, i) => (
        <li key={i} className="flex items-start gap-2.5 text-sm text-gray-300">
          <CheckCheck className="w-4 h-4 text-green-400 shrink-0 mt-0.5" /> {f}
        </li>
      ))}
    </ul>
    <button className={`w-full py-3.5 rounded-full text-sm font-bold transition-all ${hot ? 'gold-btn' : 'outline-btn'}`}>
      {hot ? 'Get Started Now' : 'Contact Sales'} <ChevronRight className="inline w-4 h-4" />
    </button>
  </motion.div>
);

/* ──────────────────────────────────────────────────
   Testimonial
────────────────────────────────────────────────── */
const Testimonial = ({ name, role, text, avatar, delay }) => (
  <motion.div {...fUp(delay)} className="glass g-card p-6 rounded-2xl flex flex-col gap-4">
    <div className="flex gap-0.5">
      {Array(5).fill(0).map((_, i) => <Star key={i} className="w-4 h-4 fill-yellow-400 text-yellow-400" />)}
    </div>
    <p className="text-gray-300 text-sm leading-relaxed flex-1">"{text}"</p>
    <div className="flex items-center gap-3 pt-3 border-t border-white/5">
      <div className={`w-10 h-10 rounded-full ${avatar} flex items-center justify-center 
        text-white font-bold text-sm shrink-0`}>{name[0]}</div>
      <div>
        <p className="text-white font-semibold text-sm">{name}</p>
        <p className="text-gray-500 text-xs">{role}</p>
      </div>
    </div>
  </motion.div>
);

/* ──────────────────────────────────────────────────
   Mock Phone
────────────────────────────────────────────────── */
const MockPhone = () => (
  <div className="phone-float relative w-[270px] mx-auto select-none">
    <div className="relative w-[270px] h-[545px] bg-gradient-to-b from-[#0d1f44] to-[#040c1e]
      rounded-[44px] border border-white/10 shadow-[0_40px_100px_rgba(0,0,0,.7)] overflow-hidden">
      {/* Notch */}
      <div className="absolute top-2 left-1/2 -translate-x-1/2 w-20 h-5 bg-black rounded-full z-10" />
      {/* Header */}
      <div className="px-4 pt-10 pb-2">
        <div className="flex justify-between items-center">
          <div>
            <p className="text-white font-bold text-sm">Hi, Arjun 👋</p>
            <p className="text-gray-400 text-[10px] flex items-center gap-1">
              <span className="inline-block w-1.5 h-1.5 bg-red-500 rounded-full" />
              Mumbai, India
            </p>
          </div>
          <div className="w-9 h-9 rounded-full bg-gradient-to-br from-blue-400 to-indigo-600" />
        </div>
      </div>
      {/* Search */}
      <div className="mx-4 my-2 bg-white/5 rounded-2xl h-8 flex items-center px-3 gap-2">
        <div className="w-3 h-3 bg-gray-500/40 rounded-full shrink-0" />
        <div className="flex-1 h-1.5 bg-gray-600/40 rounded-full" />
        <div className="w-3 h-3 bg-purple-500/50 rounded-full shrink-0" />
      </div>
      {/* Section label */}
      <div className="px-4 pt-1 pb-2 flex justify-between items-center">
        <p className="text-white font-bold text-xs">Best Offers</p>
        <p className="text-yellow-400 text-[9px] font-semibold">See all</p>
      </div>
      {/* Cards */}
      <div className="flex gap-3 px-4 overflow-x-hidden">
        <div className="shrink-0 w-[130px] rounded-2xl overflow-hidden bg-gradient-to-br from-blue-600/30 to-blue-900/50">
          <div className="h-[80px] bg-gradient-to-br from-blue-500/30 to-indigo-800/40 flex items-center justify-center">
            <Building2 className="w-8 h-8 text-blue-300/40" />
          </div>
          <div className="p-2">
            <p className="text-white text-[10px] font-bold">Luxury 3BHK</p>
            <p className="text-yellow-400 text-[10px] font-semibold">₹4.5 Cr</p>
            <div className="flex gap-1 mt-1">
              <span className="text-gray-400 text-[8px]">🛏 3</span>
              <span className="text-gray-400 text-[8px]">🛁 2</span>
            </div>
          </div>
        </div>
        <div className="shrink-0 w-[130px] rounded-2xl overflow-hidden bg-white/[0.04]">
          <div className="h-[80px] bg-gradient-to-br from-gray-700/30 to-gray-900/50 flex items-center justify-center">
            <Building2 className="w-8 h-8 text-gray-600/40" />
          </div>
          <div className="p-2">
            <p className="text-white text-[10px] font-bold">Studio Apt</p>
            <p className="text-yellow-400 text-[10px] font-semibold">₹1.2 Cr</p>
            <div className="flex gap-1 mt-1">
              <span className="text-gray-400 text-[8px]">🛏 1</span>
              <span className="text-gray-400 text-[8px]">🛁 1</span>
            </div>
          </div>
        </div>
      </div>
      {/* Story bar */}
      <div className="px-4 mt-3 flex items-center gap-2">
        {['Featured', 'Villa', 'Penthouse'].map((l, i) => (
          <div key={i} className={`text-[9px] font-bold rounded-full px-2.5 py-1
            ${i === 0 ? 'bg-yellow-400 text-[#0F2C59]' : 'bg-white/5 text-gray-400'}`}>{l}</div>
        ))}
      </div>
      {/* Nearest */}
      <div className="px-4 mt-3 space-y-1.5">
        <p className="text-white font-bold text-xs mb-2">Nearest You</p>
        {[{ t: 'Sea-view Apartment', p: '₹2.8 Cr', d: '0.5 km' }, { t: 'Office Space', p: '₹80 L', d: '1.2 km' }].map((r, i) => (
          <div key={i} className="flex justify-between items-center bg-white/[0.04] rounded-xl p-2.5">
            <div>
              <p className="text-white text-[10px] font-semibold">{r.t}</p>
              <p className="text-yellow-400 text-[9px]">{r.p}</p>
            </div>
            <span className="text-gray-500 text-[9px]">{r.d}</span>
          </div>
        ))}
      </div>
      {/* Bottom Nav */}
      <div className="absolute bottom-0 left-0 right-0 h-14 bg-[#060f1f]/95 border-t border-white/5
        flex items-center justify-around px-4">
        {[Building2, Map, MessageSquare, Bell].map((Icon, i) => (
          <div key={i} className={`relative p-2 rounded-xl ${i === 0 ? 'bg-yellow-400/15' : ''}`}>
            <Icon className={`w-[18px] h-[18px] ${i === 0 ? 'text-yellow-400' : 'text-gray-500'}`} strokeWidth={1.8} />
            {i === 2 && <span className="absolute top-1 right-1 w-1.5 h-1.5 bg-red-500 rounded-full" />}
          </div>
        ))}
      </div>
    </div>
    {/* Shadow glow */}
    <div className="absolute -bottom-8 left-1/2 -translate-x-1/2 w-44 h-16 bg-blue-700/20 blur-3xl rounded-full" />
  </div>
);

/* ──────────────────────────────────────────────────
   Main App
────────────────────────────────────────────────── */
export default function App() {
  const [videoOpen, setVideoOpen] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const h = () => setScrolled(window.scrollY > 30);
    window.addEventListener('scroll', h, { passive: true });
    return () => window.removeEventListener('scroll', h);
  }, []);

  return (
    <div className="bg-[#04091a] min-h-screen text-white">

      {/* ══════════════════════════════════════════════
          NAV
      ══════════════════════════════════════════════ */}
      <header className={`fixed top-0 w-full z-50 transition-all duration-300
        ${scrolled ? 'glass shadow-[0_1px_0_rgba(255,255,255,0.06)] py-3' : 'py-5'}`}>
        <div className="max-w-7xl mx-auto px-6 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-yellow-400 to-orange-500
              flex items-center justify-center shadow-[0_0_20px_rgba(255,215,0,.4)]">
              <Building2 className="w-5 h-5 text-[#0F2C59]" />
            </div>
            <span className="text-lg font-extrabold tracking-tight">
              Oberoi <span className="gold-text">Realty</span>
            </span>
          </div>

          <nav className="hidden md:flex items-center gap-8 text-sm text-gray-400 font-medium">
            {['Features', 'Demo', 'Pricing', 'Testimonials'].map(l => (
              <a key={l} href={`#${l.toLowerCase()}`}
                className="hover:text-white transition-colors duration-200 hover:gold-text">{l}</a>
            ))}
          </nav>

          <div className="hidden md:flex gap-3 items-center">
            <button className="outline-btn text-sm px-5 py-2.5 rounded-full">Contact Sales</button>
            <button className="gold-btn text-sm px-5 py-2.5 rounded-full">Get the App →</button>
          </div>

          <button className="md:hidden text-gray-400 hover:text-white p-1"
            onClick={() => setMenuOpen(!menuOpen)}>
            {menuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
        </div>
        <AnimatePresence>
          {menuOpen && (
            <motion.div initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }}
              exit={{ opacity: 0, height: 0 }}
              className="md:hidden glass border-t border-white/5 px-6 pb-5 flex flex-col gap-3 overflow-hidden">
              {['Features', 'Demo', 'Pricing', 'Testimonials'].map(l => (
                <a key={l} href={`#${l.toLowerCase()}`}
                  className="text-gray-300 hover:text-white py-2 border-b border-white/5 text-sm"
                  onClick={() => setMenuOpen(false)}>{l}</a>
              ))}
              <button className="gold-btn text-sm px-6 py-3 rounded-full mt-2">Get the App →</button>
            </motion.div>
          )}
        </AnimatePresence>
      </header>

      {/* ══════════════════════════════════════════════
          HERO
      ══════════════════════════════════════════════ */}
      <section className="relative min-h-screen flex items-center justify-center pt-24 pb-16 overflow-hidden px-6">
        {/* Background orbs */}
        <div className="orb w-[700px] h-[700px] bg-blue-700/18 -top-56 -left-48" style={{ animation: 'drift 12s ease-in-out infinite' }} />
        <div className="orb w-[500px] h-[500px] bg-yellow-500/8 bottom-0 right-[-150px]" style={{ animation: 'drift 9s ease-in-out infinite alternate' }} />
        <div className="orb w-[350px] h-[350px] bg-indigo-700/14 top-1/3 left-1/2" style={{ animation: 'drift 14s ease-in-out infinite reverse' }} />

        <div className="max-w-7xl mx-auto flex flex-col lg:flex-row items-center gap-16 relative z-10">
          {/* Text */}
          <motion.div initial={{ opacity: 0, x: -40 }} animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.9, ease: [0.22, 1, 0.36, 1] }}
            className="flex-1 text-center lg:text-left">

            <div className="inline-flex items-center gap-2 glass border border-yellow-500/20 rounded-full
              px-4 py-1.5 text-[11px] font-bold uppercase tracking-[0.15em] text-yellow-400 mb-8">
              <Zap className="w-3 h-3" /> Built for Elite Real Estate Agencies
            </div>

            <h1 className="text-5xl sm:text-6xl xl:text-7xl font-black leading-[1.06] tracking-[-0.02em] mb-6">
              Close Deals <br />
              <span className="shine-text">10× Faster</span>
            </h1>

            <p className="text-gray-400 text-lg leading-relaxed mb-10 max-w-xl mx-auto lg:mx-0">
              A white-label Flutter property app with voice AI, Instagram Reels, live agent chat,
              and push notifications — engineered for real estate owners ready to dominate online.
            </p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start mb-12">
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

            {/* Trust badges */}
            <div className="flex flex-wrap items-center gap-5 justify-center lg:justify-start text-xs text-gray-500 font-medium">
              <span className="flex items-center gap-1.5"><ShieldCheck className="w-4 h-4 text-green-400" /> Firebase Secured</span>
              <span className="flex items-center gap-1.5"><Users className="w-4 h-4 text-blue-400" /> 10+ Agencies Live</span>
              <span className="flex items-center gap-1.5"><Heart className="w-4 h-4 text-red-400" fill="#f87171" /> 4.9★ Rated</span>
              <span className="flex items-center gap-1.5"><Smartphone className="w-4 h-4 text-purple-400" /> Android + iOS Ready</span>
            </div>
          </motion.div>

          {/* Phone */}
          <motion.div initial={{ opacity: 0, x: 40 }} animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.9, delay: 0.2, ease: [0.22, 1, 0.36, 1] }}
            className="flex-shrink-0">
            <MockPhone />
          </motion.div>
        </div>

        <div className="absolute bottom-0 left-0 right-0 h-36 bg-gradient-to-t from-[#04091a] to-transparent" />
      </section>

      {/* ── TICKER ─────────────────────────────────── */}
      <Ticker />

      {/* ══════════════════════════════════════════════
          FEATURES
      ══════════════════════════════════════════════ */}
      <section id="features" className="py-28 px-6 bg-[#060f1f] relative">
        <div className="orb w-[500px] h-[500px] bg-blue-800/12 top-0 right-[-100px]" />
        <div className="max-w-7xl mx-auto relative z-10">
          <div className="text-center mb-16">
            <motion.p {...fUp(0)} className="text-yellow-400 text-[11px] font-bold uppercase tracking-[0.2em] mb-3">
              Built to Convert
            </motion.p>
            <motion.h2 {...fUp(0.1)} className="text-4xl sm:text-5xl font-black tracking-tight mb-4">
              Every Feature <span className="gold-text">Your Clients Love</span>
            </motion.h2>
            <motion.p {...fUp(0.2)} className="text-gray-400 text-base max-w-lg mx-auto">
              Not a demo. Not a template. A full production Flutter app ready to ship under your brand.
            </motion.p>
          </div>

          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {[
              { icon: Mic, grad: 'bg-gradient-to-br from-purple-500 to-purple-700', title: '🎙️ Voice AI Property Search', desc: 'Users speak their requirements – "3BHK in Andheri under 2Cr". A custom animated waveform visualizes listening state in real-time.', delay: 0.05 },
              { icon: Video, grad: 'bg-gradient-to-br from-rose-500 to-pink-700', title: '📱 Instagram Story Reel Player', desc: 'A draggable, magnetic floating widget pulls live Instagram Reels and plays them sequentially with progress bars — all inside the app.', delay: 0.1 },
              { icon: MessageSquare, grad: 'bg-gradient-to-br from-emerald-500 to-teal-700', title: '💬 WhatsApp-Style Agent Chat', desc: 'Firestore instant messaging with double-tick delivery receipts, read status, unread badge counters, and clickable avatar popups.', delay: 0.15 },
              { icon: Map, grad: 'bg-gradient-to-br from-blue-500 to-blue-700', title: '🗺️ Smart Cluster Map', desc: 'Properties plotted with auto-clustering. GPS-aware with live location. Zoom in for pins, zoom out for city clusters.', delay: 0.2 },
              { icon: Bell, grad: 'bg-gradient-to-br from-amber-500 to-orange-600', title: '🔔 Rich Push Notifications', desc: 'One-tap broadcast to all users with images via Firebase + Node.js backend. Pre-configured and deployable in minutes.', delay: 0.25 },
              { icon: Lock, grad: 'bg-gradient-to-br from-gray-500 to-slate-700', title: '🔐 Owner / Buyer Role System', desc: 'Separate experiences per role. Owners see add-property FAB and notification sender. Buyers see discovery-first UI.', delay: 0.3 },
            ].map(p => <FeatureCard key={p.title} {...p} />)}
          </div>
        </div>
      </section>

      {/* ══════════════════════════════════════════════
          WHY BUY (tech stack deep-dive)
      ══════════════════════════════════════════════ */}
      <section id="demo" className="py-24 px-6 relative overflow-hidden">
        <div className="orb w-[400px] h-[400px] bg-yellow-500/7 bottom-0 left-[-100px]" />
        <div className="max-w-7xl mx-auto flex flex-col lg:flex-row-reverse items-center gap-14 relative z-10">
          {/* Visual card */}
          <motion.div {...fUp(0)} className="flex-1 flex justify-center">
            <div className="grid grid-cols-2 gap-4 w-full max-w-sm">
              {[
                { label: 'Flutter + Dart', sub: 'Smooth 60fps UI', icon: Smartphone, c: 'from-blue-600/30 to-blue-900/30' },
                { label: 'Firebase Cloud', sub: 'Real-time + Auth', icon: Globe, c: 'from-orange-600/30 to-red-900/30' },
                { label: 'Node.js Backend', sub: 'Push Notifications', icon: Bell, c: 'from-green-600/30 to-green-900/30' },
                { label: 'BLoC + Provider', sub: 'Predictable State', icon: BarChart3, c: 'from-purple-600/30 to-purple-900/30' },
              ].map(({ label, sub, icon: Icon, c }, i) => (
                <motion.div key={i} {...fUp(i * 0.08 + 0.1)}
                  className={`g-card rounded-2xl p-5 bg-gradient-to-br ${c} flex flex-col gap-3`}>
                  <Icon className="w-6 h-6 text-white/60" strokeWidth={1.5} />
                  <div>
                    <p className="text-white font-bold text-sm">{label}</p>
                    <p className="text-gray-400 text-xs">{sub}</p>
                  </div>
                </motion.div>
              ))}
            </div>
          </motion.div>

          {/* Text */}
          <div className="flex-1 max-w-lg">
            <motion.p {...fUp(0)} className="text-yellow-400 text-[11px] font-bold uppercase tracking-[0.2em] mb-3">
              Skip the Dev Cost
            </motion.p>
            <motion.h2 {...fUp(0.1)} className="text-4xl font-black leading-tight tracking-tight mb-5">
              Launch in Days, <br /><span className="gold-text">Not Months.</span>
            </motion.h2>
            <motion.p {...fUp(0.2)} className="text-gray-400 leading-relaxed mb-7">
              Custom app development averages ₹5–15 lakh and 6–12 months.
              Our production-ready codebase lets your team brand, configure, and ship immediately.
            </motion.p>
            <div className="space-y-3">
              {[
                'Complete Flutter source code — no obfuscation',
                'Firebase schema + security rules included',
                'Node.js notification backend on Render/Heroku',
                'Google Play Store ready APK with custom icon',
                'Admin portal with broadcast notifications',
                'Detailed setup documentation & onboarding call',
              ].map((item, i) => (
                <motion.div key={i} {...fUp(i * 0.07 + 0.2)}
                  className="flex items-start gap-3 glass rounded-xl p-3.5">
                  <CheckCheck className="w-4 h-4 text-green-400 mt-0.5 shrink-0" />
                  <p className="text-gray-200 text-sm">{item}</p>
                </motion.div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* ══════════════════════════════════════════════
          STATS
      ══════════════════════════════════════════════ */}
      <section id="stats" className="py-20 px-6 bg-[#060f1f] border-y border-white/5">
        <div className="max-w-5xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-5">
          <Stat val="6×" label="Faster to market vs custom dev" icon={Zap} delay={0} />
          <Stat val="100%" label="Source code ownership" icon={ShieldCheck} delay={0.1} />
          <Stat val="99.9%" label="Firebase backend uptime" icon={Globe} delay={0.2} />
          <Stat val="10+" label="Agencies already live" icon={Building2} delay={0.3} />
        </div>
      </section>

      {/* ══════════════════════════════════════════════
          PRICING
      ══════════════════════════════════════════════ */}
      <section id="pricing" className="py-28 px-6 relative overflow-hidden">
        <div className="orb w-[600px] h-[600px] bg-blue-900/15 top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2" />
        <div className="max-w-6xl mx-auto relative z-10">
          <div className="text-center mb-16">
            <motion.p {...fUp(0)} className="text-yellow-400 text-[11px] font-bold uppercase tracking-[0.2em] mb-3">Pricing</motion.p>
            <motion.h2 {...fUp(0.1)} className="text-4xl sm:text-5xl font-black tracking-tight mb-4">
              One License. <span className="gold-text">Fully Yours.</span>
            </motion.h2>
            <motion.p {...fUp(0.2)} className="text-gray-400 text-base">No subscriptions. No royalties. Pay once, own forever.</motion.p>
          </div>
          <div className="grid md:grid-cols-3 gap-6">
            <PricingCard tier="Starter" price="₹49,999" note="one-time" delay={0.1}
              features={['Full Flutter Source Code', 'Firebase Integration Guide', 'Google Play Ready APK', 'Custom Splash & Icon', '3 Months Email Support']} />
            <PricingCard tier="Professional" price="₹99,999" note="one-time" delay={0.15} hot
              features={['Everything in Starter', 'Node.js Backend Included', 'Instagram Reel Integration', 'Owner/Buyer Role System', '6 Months Priority Support', 'Onboarding Call (60 min)']} />
            <PricingCard tier="Enterprise" price="Custom" delay={0.2}
              features={['Everything in Pro', 'On-demand Feature Builds', 'Dedicated Slack Channel', '12-Month SLA Support', 'iOS Build Assistance', 'NDA + Source Escrow']} />
          </div>
        </div>
      </section>

      {/* ══════════════════════════════════════════════
          TESTIMONIALS
      ══════════════════════════════════════════════ */}
      <section id="testimonials" className="py-28 px-6 bg-[#060f1f]">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <motion.p {...fUp(0)} className="text-yellow-400 text-[11px] font-bold uppercase tracking-[0.2em] mb-3">Social Proof</motion.p>
            <motion.h2 {...fUp(0.1)} className="text-4xl font-black tracking-tight">
              Realtors <span className="gold-text">Love It.</span>
            </motion.h2>
          </div>
          <div className="grid md:grid-cols-3 gap-5">
            <Testimonial name="Rahul Mehta" role="MD, Prestige Homes, Pune" avatar="bg-gradient-to-br from-blue-500 to-indigo-700" delay={0.05}
              text="Launched our branded app in under 2 weeks. The voice search and WhatsApp-style chat alone closed 3 premium clients in Month 1. Truly remarkable product." />
            <Testimonial name="Priya Sharma" role="Director, Elite Properties, Mumbai" avatar="bg-gradient-to-br from-pink-500 to-rose-700" delay={0.1}
              text="The Instagram story video player is jaw-dropping. Our marketing reels now play directly inside the app. Buyers engage 3× longer than on our website." />
            <Testimonial name="Ankit Joshi" role="CTO, GoldKey Realty, Delhi" avatar="bg-gradient-to-br from-emerald-500 to-teal-700" delay={0.15}
              text="Code quality is exceptional. Push notifications to 5,000+ users configured in 30 minutes. The Firebase architecture is clean, scalable, and well-documented." />
          </div>
        </div>
      </section>

      {/* ══════════════════════════════════════════════
          CTA
      ══════════════════════════════════════════════ */}
      <section id="contact" className="py-24 px-6 relative overflow-hidden">
        <div className="orb w-[700px] h-[700px] bg-blue-700/15 top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2" />
        <div className="max-w-3xl mx-auto text-center relative z-10">
          <motion.div {...fUp(0)}
            className="glass g-card rounded-3xl p-12 sm:p-16">
            <p className="text-yellow-400 text-[11px] font-bold uppercase tracking-[0.2em] mb-4">Ready to Launch?</p>
            <h2 className="text-4xl sm:text-5xl font-black mb-5 tracking-tight leading-tight">
              Your App, <span className="gold-text">Live in 2 Weeks.</span>
            </h2>
            <p className="text-gray-400 text-base mb-10 leading-relaxed">
              Schedule a free 30-minute demo. We'll walk you through the full source code,
              branding process, and Firebase setup live on screen.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <button className="gold-btn px-10 py-4 rounded-full text-base">
                Book a Free Demo <ArrowUpRight className="inline w-5 h-5 ml-1" />
              </button>
              <button className="outline-btn px-10 py-4 rounded-full text-base">💬 WhatsApp Us</button>
            </div>
          </motion.div>
        </div>
      </section>

      {/* ══════════════════════════════════════════════
          FOOTER
      ══════════════════════════════════════════════ */}
      <footer className="border-t border-white/5 py-8 px-6">
        <div className="max-w-7xl mx-auto flex flex-col sm:flex-row justify-between items-center gap-4 text-xs text-gray-600">
          <div className="flex items-center gap-2">
            <Building2 className="w-4 h-4 text-yellow-400" />
            <span className="text-gray-400 font-semibold">Oberoi Realty</span>
          </div>
          <p>© {new Date().getFullYear()} Oberoi Software Solutions. All rights reserved.</p>
          <div className="flex gap-5 text-gray-500">
            <a href="#" className="hover:text-white transition-colors">Privacy</a>
            <a href="#" className="hover:text-white transition-colors">Terms</a>
            <a href="#" className="hover:text-white transition-colors">Contact</a>
          </div>
        </div>
      </footer>

      {/* ══════════════════════════════════════════════
          VIDEO MODAL
      ══════════════════════════════════════════════ */}
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
              <p className="text-sm">Product demo video would embed here.</p>
              <button onClick={() => setVideoOpen(false)}
                className="mt-3 text-xs underline hover:text-white transition-colors">Close</button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

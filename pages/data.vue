<template>
  <div class="page-container">
    <div class="page-header">
      <h1>Data Management</h1>
      <p>Reference data for dropdowns and system configuration</p>
    </div>
    
    <!-- Cambodia Provinces Section -->
    <div class="data-section">
      <div class="section-header">
        <h2>🇰🇭 Cambodia Provinces & Cities</h2>
        <p>Complete list of all 25 provinces and cities in Cambodia</p>
      </div>
      
      <div class="provinces-grid">
        <div 
          v-for="(province, index) in cambodiaProvinces" 
          :key="index"
          class="province-card"
        >
          <div class="province-number">{{ index + 1 }}</div>
          <div class="province-info">
            <h3>{{ province.name }}</h3>
            <p class="province-type">{{ province.type }}</p>
            <p class="province-description">{{ province.description }}</p>
          </div>
        </div>
      </div>
      
    </div>
    
    <!-- Channel Data Section -->
    <div class="data-section">
      <div class="section-header">
        <h2>📱 Social Media Channels</h2>
        <p>Popular social media platforms for marketing and communication</p>
      </div>
      
      <div class="channels-grid">
        <div 
          v-for="(channel, index) in socialChannels" 
          :key="index"
          class="channel-card"
          :class="channel.name.toLowerCase()"
        >
          <div class="channel-icon">
            <span v-html="channel.icon"></span>
          </div>
          <div class="channel-info">
            <h3>{{ channel.name }}</h3>
            <p class="channel-type">{{ channel.type }}</p>
            <p class="channel-description">{{ channel.description }}</p>
          </div>
        </div>
      </div>
      
    </div>
  </div>
</template>

<script setup lang="ts">
// Apply authentication middleware
definePageMeta({
  middleware: 'auth'
})

// Data management page with hardcoded reference data

interface Province {
  name: string
  type: 'Province' | 'City'
  description: string
}

interface Channel {
  name: string
  type: string
  description: string
  icon: string
}

// Cambodia's 25 provinces and cities
const cambodiaProvinces: Province[] = [
  {
    name: "Phnom Penh",
    type: "City",
    description: "Capital city and largest urban center"
  },
  {
    name: "Banteay Meanchey",
    type: "Province",
    description: "Northwestern province bordering Thailand"
  },
  {
    name: "Battambang",
    type: "Province",
    description: "Major agricultural province in the northwest"
  },
  {
    name: "Kampong Cham",
    type: "Province",
    description: "Central province along the Mekong River"
  },
  {
    name: "Kampong Chhnang",
    type: "Province",
    description: "Central province known for pottery"
  },
  {
    name: "Kampong Speu",
    type: "Province",
    description: "Province southwest of Phnom Penh"
  },
  {
    name: "Kampong Thom",
    type: "Province",
    description: "Central province with ancient temples"
  },
  {
    name: "Kampot",
    type: "Province",
    description: "Southern province famous for pepper"
  },
  {
    name: "Kandal",
    type: "Province",
    description: "Province surrounding Phnom Penh"
  },
  {
    name: "Kep",
    type: "City",
    description: "Coastal city and former beach resort"
  },
  {
    name: "Koh Kong",
    type: "Province",
    description: "Southwestern province with pristine beaches"
  },
  {
    name: "Kratie",
    type: "Province",
    description: "Northeastern province on the Mekong"
  },
  {
    name: "Mondulkiri",
    type: "Province",
    description: "Eastern highland province with ethnic minorities"
  },
  {
    name: "Oddar Meanchey",
    type: "Province",
    description: "Northern province bordering Thailand"
  },
  {
    name: "Pailin",
    type: "City",
    description: "Former Khmer Rouge stronghold"
  },
  {
    name: "Preah Sihanouk",
    type: "Province",
    description: "Coastal province with Sihanoukville city"
  },
  {
    name: "Preah Vihear",
    type: "Province",
    description: "Northern province with ancient temple"
  },
  {
    name: "Pursat",
    type: "Province",
    description: "Central province with Cardamom Mountains"
  },
  {
    name: "Prey Veng",
    type: "Province",
    description: "Southeastern province with agricultural focus"
  },
  {
    name: "Ratanakiri",
    type: "Province",
    description: "Northeastern highland province"
  },
  {
    name: "Siem Reap",
    type: "Province",
    description: "Home to the famous Angkor temples"
  },
  {
    name: "Stung Treng",
    type: "Province",
    description: "Northern province on the Mekong River"
  },
  {
    name: "Svay Rieng",
    type: "Province",
    description: "Southeastern province bordering Vietnam"
  },
  {
    name: "Takeo",
    type: "Province",
    description: "Southern province with ancient sites"
  },
  {
    name: "Tbong Khmum",
    type: "Province",
    description: "Eastern province created in 2013"
  }
]

// Social Media Channels data
const socialChannels: Channel[] = [
  {
    name: "Facebook",
    type: "Social Network",
    description: "World's largest social networking platform",
    icon: `<svg viewBox="0 0 24 24" fill="currentColor" width="24" height="24">
      <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
    </svg>`
  },
  {
    name: "Instagram",
    type: "Photo Sharing",
    description: "Visual content sharing and social networking",
    icon: `<svg viewBox="0 0 24 24" fill="currentColor" width="24" height="24">
      <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
    </svg>`
  },
  {
    name: "Telegram",
    type: "Messaging",
    description: "Secure messaging and communication platform",
    icon: `<svg viewBox="0 0 24 24" fill="currentColor" width="24" height="24">
      <path d="M11.944 0A12 12 0 0 0 0 12a12 12 0 0 0 12 12 12 12 0 0 0 12-12A12 12 0 0 0 12 0a12 12 0 0 0-.056 0zm4.962 7.224c.1-.002.321.023.465.14a.506.506 0 0 1 .171.325c.016.093.036.306.02.472-.18 1.898-.962 6.502-1.36 8.627-.168.9-.499 1.201-.82 1.23-.696.065-1.225-.46-1.9-.902-1.056-.693-1.653-1.124-2.678-1.8-1.185-.78-.417-1.21.258-1.91.177-.184 3.247-2.977 3.307-3.23.007-.032.014-.15-.056-.212s-.174-.041-.249-.024c-.106.024-1.793 1.14-5.061 3.345-.48.33-.913.49-1.302.48-.428-.008-1.252-.241-1.865-.44-.752-.245-1.349-.374-1.297-.789.027-.216.325-.437.893-.663 3.498-1.524 5.83-2.529 6.998-3.014 3.332-1.386 4.025-1.627 4.476-1.635z"/>
    </svg>`
  },
  {
    name: "TikTok",
    type: "Video Platform",
    description: "Short-form video content and entertainment",
    icon: `<svg viewBox="0 0 24 24" fill="currentColor" width="24" height="24">
      <path d="M12.525.02c1.31-.02 2.61-.01 3.91-.02.08 1.53.63 3.09 1.75 4.17 1.12 1.11 2.7 1.62 4.24 1.79v4.03c-1.44-.05-2.89-.35-4.2-.97-.57-.26-1.1-.59-1.62-.93-.01 2.92.01 5.84-.02 8.75-.08 1.4-.54 2.79-1.35 3.94-1.31 1.92-3.58 3.17-5.91 3.21-1.43.08-2.86-.31-4.08-1.03-2.02-1.19-3.44-3.37-3.65-5.71-.02-.5-.03-1-.01-1.49.18-1.9 1.12-3.72 2.58-4.96 1.66-1.44 3.98-2.13 6.15-1.72.02 1.48-.04 2.96-.04 4.44-.99-.32-2.15-.23-3.02.37-.63.41-1.11 1.04-1.36 1.75-.21.51-.15 1.07-.14 1.61.24 1.64 1.82 3.02 3.5 2.87 1.12-.01 2.19-.66 2.77-1.61.19-.33.4-.67.41-1.06.1-1.79.06-3.57.07-5.36.01-4.03-.01-8.05.02-12.07z"/>
    </svg>`
  }
]

</script>

<style scoped>
.page-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.page-header {
  text-align: center;
  margin-bottom: 3rem;
}

.page-header h1 {
  font-size: 2.5rem;
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.page-header p {
  font-size: 1.1rem;
  color: #7f8c8d;
}

.data-section {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  margin-bottom: 2rem;
}

.section-header {
  text-align: center;
  margin-bottom: 2rem;
}

.section-header h2 {
  font-size: 2rem;
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.section-header p {
  color: #7f8c8d;
  font-size: 1rem;
}

.provinces-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
  margin-bottom: 3rem;
}

.province-card {
  display: flex;
  align-items: center;
  background: #f8f9fa;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  padding: 1rem;
  transition: all 0.3s ease;
}

.province-card:hover {
  border-color: #007bff;
  box-shadow: 0 4px 12px rgba(0, 123, 255, 0.15);
  transform: translateY(-2px);
}

.province-number {
  background: #007bff;
  color: white;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  margin-right: 1rem;
  flex-shrink: 0;
}

.province-info h3 {
  margin: 0 0 0.25rem 0;
  color: #2c3e50;
  font-size: 1.1rem;
}

.province-type {
  margin: 0 0 0.25rem 0;
  color: #007bff;
  font-size: 0.9rem;
  font-weight: 500;
}

.province-description {
  margin: 0;
  color: #6c757d;
  font-size: 0.85rem;
  line-height: 1.4;
}


/* Channel Cards Styles */
.channels-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1.5rem;
  margin-bottom: 3rem;
}

.channel-card {
  display: flex;
  align-items: center;
  background: #f8f9fa;
  border: 2px solid #e9ecef;
  border-radius: 12px;
  padding: 1.5rem;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.channel-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.channel-card.facebook {
  border-color: #1877f2;
  background: linear-gradient(135deg, #f8f9fa 0%, #e3f2fd 100%);
}

.channel-card.facebook:hover {
  box-shadow: 0 8px 25px rgba(24, 119, 242, 0.3);
}

.channel-card.instagram {
  border-color: #e4405f;
  background: linear-gradient(135deg, #f8f9fa 0%, #fce4ec 100%);
}

.channel-card.instagram:hover {
  box-shadow: 0 8px 25px rgba(228, 64, 95, 0.3);
}

.channel-card.telegram {
  border-color: #0088cc;
  background: linear-gradient(135deg, #f8f9fa 0%, #e1f5fe 100%);
}

.channel-card.telegram:hover {
  box-shadow: 0 8px 25px rgba(0, 136, 204, 0.3);
}

.channel-card.tiktok {
  border-color: #000000;
  background: linear-gradient(135deg, #f8f9fa 0%, #f5f5f5 100%);
}

.channel-card.tiktok:hover {
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.3);
}

.channel-icon {
  width: 50px;
  height: 50px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  margin-right: 1rem;
  flex-shrink: 0;
  background: white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.channel-icon svg {
  width: 24px;
  height: 24px;
  transition: all 0.3s ease;
}

/* Brand colors for each social media platform */
.channel-card.facebook .channel-icon {
  background: #1877f2;
  color: white;
}

.channel-card.facebook:hover .channel-icon {
  background: #166fe5;
  transform: scale(1.1);
}

.channel-card.instagram .channel-icon {
  background: linear-gradient(45deg, #f09433 0%, #e6683c 25%, #dc2743 50%, #cc2366 75%, #bc1888 100%);
  color: white;
}

.channel-card.instagram:hover .channel-icon {
  transform: scale(1.1);
}

.channel-card.telegram .channel-icon {
  background: #0088cc;
  color: white;
}

.channel-card.telegram:hover .channel-icon {
  background: #0077b5;
  transform: scale(1.1);
}

.channel-card.tiktok .channel-icon {
  background: #000000;
  color: white;
}

.channel-card.tiktok:hover .channel-icon {
  background: #333333;
  transform: scale(1.1);
}

.channel-info h3 {
  margin: 0 0 0.25rem 0;
  color: #2c3e50;
  font-size: 1.2rem;
  font-weight: 600;
}

.channel-type {
  margin: 0 0 0.5rem 0;
  color: #6c757d;
  font-size: 0.9rem;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.channel-description {
  margin: 0;
  color: #6c757d;
  font-size: 0.9rem;
  line-height: 1.4;
}

/* Responsive Design */
@media (max-width: 768px) {
  .page-container {
    padding: 1rem;
  }
  
  .provinces-grid {
    grid-template-columns: 1fr;
  }
  
  .channels-grid {
    grid-template-columns: 1fr;
  }
  
}

@media (max-width: 480px) {
  .province-card {
    flex-direction: column;
    text-align: center;
  }
  
  .province-number {
    margin-right: 0;
    margin-bottom: 1rem;
  }
  
  .channel-card {
    flex-direction: column;
    text-align: center;
  }
  
  .channel-icon {
    margin-right: 0;
    margin-bottom: 1rem;
  }
}
</style>

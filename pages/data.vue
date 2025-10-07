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
    icon: "📘"
  },
  {
    name: "Instagram",
    type: "Photo Sharing",
    description: "Visual content sharing and social networking",
    icon: "📷"
  },
  {
    name: "Telegram",
    type: "Messaging",
    description: "Secure messaging and communication platform",
    icon: "✈️"
  },
  {
    name: "TikTok",
    type: "Video Platform",
    description: "Short-form video content and entertainment",
    icon: "🎵"
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

<template>
  <div id="app">
    <main>
      <section class="player">
        <div class="cover-wrapper">
          <img v-bind:class="coverObject" :src="current.cover"/>
        </div>
        <div class="song-details">
          <h2 class="song-title">
            {{ current.title }}
          </h2>
<!--          <p class="artist">{{ current.artist }}</p>-->
          <p class="artist">{{ current.bpm.toFixed(1) }}</p>
          <p class="artist">{{ current.key }}</p>
          <p class="artist">{{ current.scale }}</p>
          <p class="artist">danceability : {{ current.danceability.toFixed(1) * 100 + ' %'}}</p>
          <p class="artist">happy : {{ current.happy.toFixed(1) * 100 + ' %'}}</p>
          <p class="artist">sad : {{ current.sad.toFixed(1) * 100 + ' %'}}</p>
          <KProgress
              :show-text="false"
              class="progress-bar-wrapper"
              v-bind:percent="current.percent"
              :color="['#df83f1', '#82279f', '#53cfe0']"
          />
          <div class="timer">
            <p class="start">{{ currentlyTimer }}</p>
            <p class="end">
              {{ current.totalTimer }}
            </p>
          </div>
        </div>
        <div class="controls">
          <button class="prev" @click="prev" v-if="songs.length > 1">
            <font-awesome-icon icon="step-backward"/>
          </button>
          <button class="play" v-if="!isPlaying" @click="play">
            <font-awesome-icon icon="play"/>
          </button>
          <button class="pause" v-else @click="pause">
            <font-awesome-icon icon="pause"/>
          </button>
          <button class="next" @click="next" v-if="songs.length > 1">
            <font-awesome-icon icon="step-forward"/>
          </button>
        </div>
<!--        <div class="footer">
          <p>Powered by Soundcloud</p>
          <a
              href="https://github.com/Davigl/vue-music-player"
              alt="Give a Star"
              title="Give a Star"
          >
            <font-awesome-icon :icon="['fab', 'github']"/>
          </a>
        </div>-->
      </section>
    </main>
    <section class="playlist">
      <h3>Now Playing <span> 🎵 </span></h3>
      <ul>
        <li v-for="song in songs" :key="song.src" class="song">
          <div class="cover-playlist">
            <img class="cover" :src="song.cover"/>
          </div>
          <div class="details" @click="play(song)">
            <h2 class="song-title">
              {{ song.title }}
            </h2>
            <p class="artist">{{ song.artist }}</p>
            <KProgress
                v-if="song.isPlaying"
                :color="['#df83f1', '#82279f', '#53cfe0']"
                :show-text="false"
                class="progress-bar-wrapper"
                v-bind:percent="song.percent"
            />
          </div>
          <div class="actions">
            <button @click="removeSongFromPlaylist(song)" class="delete">
              <font-awesome-icon icon="times"/>
            </button>
          </div>
        </li>
      </ul>
    </section>
    <section class="playlist">
      <h3>Related / Simmilar Songs <span> 🎵 </span></h3>
      <ul>
        <li v-for="song in matches" :key="song.src" class="song">
          <div class="cover-playlist">
            <img class="cover" :src="song.cover"/>
          </div>
          <div class="details" @click="play(song)">
            <h2 class="song-title">
              {{ song.title }}
            </h2>
<!--            <p class="artist">{{ song.artist }}</p>-->
            <p class="artist">{{ song.bpm.toFixed(1) }}</p>
            <p class="artist">{{ song.key }}</p>
            <p class="artist">{{ song.scale }}</p>
            <p class="artist">danceability : {{ song.danceability.toFixed(1) * 100 + ' %' }}</p>
            <p class="artist">happy : {{ song.happy.toFixed(1) * 100 + ' %' }}</p>
            <p class="artist">sad : {{ current.sad.toFixed(1) * 100 + ' %'}}</p>
            <KProgress
                v-if="song.isPlaying"
                :color="['#df83f1', '#82279f', '#53cfe0']"
                :show-text="false"
                class="progress-bar-wrapper"
                v-bind:percent="song.percent"
            />
          </div>
          <div class="actions">
            <button @click="removeSongFromPlaylist(song)" class="delete">
              <font-awesome-icon icon="times"/>
            </button>
          </div>
        </li>
      </ul>
    </section>
  </div>
</template>

<script>
import KProgress from "k-progress";

import {formatTimer} from "./helpers/timer";
import {deleteElement, shuffleArray, threatSongs} from "./helpers/utils";
import songs from "./mocks/songs";
import axios from 'axios'

export default {
  components: {KProgress},
  name: "App",
  data() {
    return {
      current: {},
      coverObject: {cover: true, animated: false},
      index: 0,
      isPlaying: false,
      currentlyTimer: "00:00",
      songs: shuffleArray(songs),
      matches:[],
      player: new Audio()
    };
  },
  methods: {
    listenersWhenPlay() {
      this.player.addEventListener("timeupdate", () => {
        var playerTimer = this.player.currentTime;

        this.currentlyTimer = formatTimer(playerTimer);
        this.current.percent = (playerTimer * 100) / this.current.seconds;
        this.current.isPlaying = true;
      });
      this.player.addEventListener(
          "ended",
          function () {
            this.next();
          }.bind(this)
      );
    },
    setCover() {
      this.coverObject.animated = true;

      setTimeout(() => {
        this.coverObject.animated = false;
      }, 1000);
    },
    setCurrentSong() {
      this.current = this.songs[this.index];
      this.play(this.current);
      this.setCover();
    },
    play(song) {
      //  song.src = "http://mage.tech:8899/storage/audio/Dotorado%20Pro%20-%20Say%20Daddy%20-%20Dotorado%20Pro.mp3"
      if (typeof song.src !== "undefined") {
        this.current.isPlaying = false;
        this.index = this.songs.indexOf(this.current);
        this.current = song;
        this.player.src = this.current.src;
      }
      this.matches = []

      this.getRelatedSongs(song.related_songs)

      this.player.play();
      this.isPlaying = true;

      this.setCover();
      this.listenersWhenPlay();
    },
    pause() {
      this.player.pause();
      this.isPlaying = false;
    },
    next() {
      this.current.isPlaying = false;
      this.index = this.songs.indexOf(this.current);
      this.index++;
      if (this.index > this.songs.length - 1) {
        this.index = 0;
      }
      this.setCurrentSong();
    },
    prev() {
      this.current.isPlaying = false;
      this.index = this.songs.indexOf(this.current);
      this.index--;
      if (this.index < 0) {
        this.index = this.songs.length - 1;
      }
      this.setCurrentSong();
    },
    removeSongFromPlaylist(song) {
      if (this.songs.length > 1) {
        if (this.index > 0) {
          this.index--;
        }
        this.current.isPlaying = false;
        this.songs = deleteElement(this.songs, song);
        this.setCurrentSong();
      }
    },
    async getAllSongFromApi() {

      let allSongs = await axios.get('http://mage.tech:8899/api/songs').then(res => {
        let songs = res.data.data

        songs.forEach((song) => {
          let newSong =
              {
                title: song.title,
                artist: song.title,
                seconds: 204,
                cover: require('/home/atem/sites/curator/vue-music-player/src/assets/images/azealia banks - jumanji.jpg'),
                src: song.path,
                related_songs: song.related_songs,
                bpm : song.bpm,
                key : song.key,
                scale : song.scale,
                danceability : song.danceability,
                happy : song.happy,
                sad : song.sad,
              }

          this.songs.push(newSong)
        })
      }).catch((err) => {
        console.log(err)
      })
      return allSongs;
    },

    getRelatedSongs(url){

      console.log({url})
     axios.get(url).then(res => {
        let songs = res.data.hits
       console.log(songs)

        songs.forEach((song) => {
          let newSong =
              {
                title: song.title,
                artist: song.title,
                seconds: 204,
                cover: require('/home/atem/sites/curator/vue-music-player/src/assets/images/azealia banks - jumanji.jpg'),
                src: song.path,
                bpm : song.bpm,
                key : song.key,
                scale : song.scale,
                danceability : song.danceability,
                happy : song.happy,
                sad : song.sad,
              }

          this.matches.push(newSong)
        })
      }).catch((err) => {
        console.log(err)
      })
     // return matches;
    }
  },
  mounted() {
    this.getAllSongFromApi()
    this.songs = threatSongs(this.songs);
    this.current = this.songs[this.index];
    this.player.src = this.current.src;
  }
};
</script>

<style>
@import "./assets/styles/main.css";
</style>

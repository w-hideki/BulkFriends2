class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,:recoverable, :rememberable, :validatable
  validates :nickname, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  validates :password, presence: true, length: { minimum: 7 }, format: { with: /(?=.*\d+.*)(?=.*[a-zA-Z]+.*)./ }
  validates :introduction, length: { maximum: 290 }

  #アバター
  has_one_attached :avatar

  #友達機能
  has_many :following_relationships, foreign_key: "follower_id", class_name: "Relationship", dependent: :destroy
  has_many :followings, through: :following_relationships
  has_many :follower_relationships, foreign_key: "following_id", class_name: "Relationship", dependent: :destroy
  has_many :followers, through: :follower_relationships

  #メッセージ機能
  has_many :messages, dependent: :destroy
  has_many :sent_messages, through: :messages, source: :receive_user
  has_many :reverses_of_message, class_name: 'Message', foreign_key: 'receive_user_id'
  has_many :received_messages, through: :reverses_of_message, source: :user

  #トレーニングメモ機能
  has_many :trainings, dependent: :destroy

  #Mygym機能
  has_one :mygym, dependent: :destroy
  has_many :tweets, dependent: :destroy

  def following?(other_user)
    following_relationships.find_by(following_id: other_user.id)
  end

  def follow!(other_user)
    following_relationships.create!(following_id: other_user.id)
  end

  def unfollow!(other_user)
    following_relationships.find_by(following_id: other_user.id).destroy
  end

  def matchers
    followings & followers
  end

  def self.search(nickname)
    if nickname
      User.where(['nickname LIKE ?', "%#{nickname}%"])
    else
      User.all
    end
  end

end

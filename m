Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.215.179
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795393279;
	b=CG0PcvfQZ/okVCeUfmt5Kvr4Pbc3VQJNLkUDiEKnoK9OSlHxBhtecEKrZT2uq8vGLBCA
	 v+LhCJYNpPITFROr0qd50iYNlRd8+eVjrRa4K4roe9cGcsEsBanlt/XYBTKE+dp/n+aSv
	 fONl0Ldh79eGnpP8M7TUT5J0CbUYLtCesjXtuZRQjPsipTNe7Xl+KMG1ypFw/Gz7mWEky
	 +2WOWL8F7c65co4EAb7j/2xFOYocBWQPp+mwJKx7dCbL/FSulppalMs67Hij1YfZXnS51
	 k+krobkpJ6L1bdoeLvv2FrXvdo7p0pbbSQHu88nHZvNQkbC67rQ7o0Uaz0KUSr7AzKw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795393279;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Content-Type:Date:Message-Id:Cc:Subject:From:To:In-Reply-To:
	 References:Content-Transfer-Encoding:MIME-Version;
	bh=KF23iyWwR5yZnzbUCvNMaMixSGrIyVPB1oghCsOfI4k=;
	b=MlQFlalV8pYbfSAQwJXnZGGRuC0FudC/nV2egRPZmEHxbweIVb2tu5DvJzlR8n95s0OC
	 sTLp22JQlQAYf9UI8SwSApFGkDMdu1Je05z0Uuqrbrf94LcTpWohxmW92b2cDup+OQvYS
	 YkMgXAiN1RrD4G59yezl0hDkkjZoXkZZx4nNjnmE3AqT8mL3qIbf/atbPW3TaFFrdW9bP
	 CeHESGDttt1JMItkfIcmVVAU2AXzFpFrJf845y0jGltDHcxHvZ1c1GFa9Lkxjq8rRM9u3
	 OCvNrzVKjIAQGhJ//AUGubM80LrIj2P+4N07kiBMmG8MOFBxAfhBsK4O1lMZ0DjmrqA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=uAriEHlZ;
	arc=none smtp.remote-ip=209.85.215.179
Received: from mail-pg1-f179.google.com (mail-pg1-f179.google.com [209.85.215.179])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 25341606A320
	for <containers@lists.linux.dev>; Mon, 23 Nov 2026 00:21:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 25341606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=uAriEHlZ
Received: by mail-pg1-f179.google.com with SMTP id 41be03b00d2f7-cddac941ed1so1026017a12.2
        for <containers@lists.linux.dev>; Sun, 22 Nov 2026 16:21:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795393278; x=1795998078; darn=lists.linux.dev;
        h=mime-version:content-transfer-encoding:references:in-reply-to:to
         :from:subject:cc:message-id:date:content-type:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=KF23iyWwR5yZnzbUCvNMaMixSGrIyVPB1oghCsOfI4k=;
        b=uAriEHlZl9KM2ACvegUu2BtH1R0AC/sAlXX3n8YdltVvV3ygkdqkJEPLPY+p+RU+79
         qxP6fJdS1PSd5ggxvjYWTqJRTbDsEHC57GX600/0Y17TXOzd2x1EzqQynacgwcx/UjhM
         75SX4/758lHiJfSQmeWRN5dkavW+Wsko1zXafMwuR23r0b5XIAeMhh7stiLUuw99uKRT
         0Dk5coWFv7RuCVH1oXvOnKxP+t/awGHDtXvlSQDW7BCSMa3S/yOYTKyhn+zvi5v+BCfH
         gsEIhZY2Tl7XMkM3D7tzncPKznWxXLhYdxqTUW5vMHPGKs/pYB1fm/Y7YostT2HazocY
         Zwbw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795393278; x=1795998078;
        h=mime-version:content-transfer-encoding:references:in-reply-to:to
         :from:subject:cc:message-id:date:content-type:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=KF23iyWwR5yZnzbUCvNMaMixSGrIyVPB1oghCsOfI4k=;
        b=cxpyj0p9ygQhyzRCpFCS+eVmBXhUEuVK4WbZMvT0tPKBo99r7iZWolGKR3Q5KDUgpi
         A65vJHR7tYzIzuMIgRyI6J1lWq61th9vb4gGFGSrI5pEmSgvp+FKn56D3wFcDBIRrBdR
         O4sN42a0Cb8YpwyWu2LJHCW24GtILMVElon/Lad6Kk3qMHEg/74Yq3cjYpUmx/KugVta
         BjB2t7zdvpL0ag1O3M+V16e3NNTWC7AJbvD3FJ5WGJTozhhh5NbHeIk6bs7oB48V7ZYO
         XdAdy9ibAcJnVaHXu0zlrxr7rtvvubSUpbdGg7KzwGuOKmjYxfwLBpISCKdmxn9efR4Y
         nwBQ==
X-Forwarded-Encrypted: i=1; AL+hErFTtqLdo/Iivqu/wgjylJ5T4scL95m9BvOiKTbfN4iBY5FlivIwmZWa/7J2MRsi5Q1ZXF8Bi5zj4/JZ@lists.linux.dev
X-Gm-Message-State: APuU4Z/ncioO7oMnq/hPEyKMio1X/OnwjkMxJHINsngGmM0wHZcgtIgN
	phg3IwHBzFB0jBOJcqeE58FRaOK8b/EoHbahG/jMoS0qeQbpo3NZn7tY
X-Gm-Gg: AZFdTZd09jb0Oa4OWEF+xoub7SnCuaVOclkTpsWhc9MhsDRBO2VSww/H/CGynYoyAu3
	QU/ib5JXABiefT+9ftZbnQFjk95mf/uRciRWQkKgsi+R463W0iY+6x58R6BVuiPSvNifw0zyxpU
	TiCOsZty2SbSAIuW84C3zENVHqJN1VvdGPxI7z3HSaFoBJ2CSt0IelkXPYl7BKaAJixwxWqY3+e
	UkAXckbjgVlfVSrKe8r+HRKSmXdEtxiAsf9uZCM5OCODe2yVHYdOktmQzq0psWqTupEyd51yQa6
	k2CqWPegfFVxenCp4vGgHgutrj1sDOwFZ1Es9gLk9bCRNF05Q5TqMTDA7h7IUeY/uyaGiuGiYc7
	8dd8ZDlF94XiSErk8BBwo7KUnPWS6RtuPQCAQ5X+0AsuStDWveeee3GNtdmVbmP+skvmwjwbRnA
	e/9yiCpkinU9YHSyEj67Zf64M7gEMAyGVCqVd8zmo/wL2WOPAVNI/VSrDLu1WaZWOfG0nkApJ5t
	lGAHeQdkajVCepMFZDqba1JFhrpC0l/ad6XRIdhzF4YILBbcft0szo0ZPeYhSKzAaafUnlUbb/w
	TmfAKHRrl49xVlisZCFWQlu4SFVAONC7vSrOfJEEMnXOz1ZzYoil4hGcTP3avczaI5ystcZ0rKU
	2dYvAJxVN5WIC0pUcyIXbMgyUTkk3ve5+hQ0=
X-Received: by 2002:a17:90b:1801:b0:3b0:9984:18c9 with SMTP id 98e67ed59e1d1-3b41c8e16efmr9088622a91.11.1795393278264;
        Sun, 22 Nov 2026 16:21:18 -0800 (PST)
Received: from localhost ([153.61.198.247])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3b44b8733e6sm4860403a91.3.2026.11.22.16.21.17
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sun, 22 Nov 2026 16:21:17 -0800 (PST)
Content-Type: text/plain; charset=UTF-8
Date: Mon, 23 Nov 2026 00:21:16 +0000
Message-Id: <DN25ST0D5K1J.1NI5236BF2BPY@gmail.com>
Cc: <bpf@vger.kernel.org>, <containers@lists.linux.dev>,
 <linux-api@vger.kernel.org>, <linux-arch@vger.kernel.org>,
 <linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
 <linux-kselftest@vger.kernel.org>, <linux-mm@kvack.org>,
 <linux-security-module@vger.kernel.org>, "Aleksa Sarai"
 <aleksa@amutable.com>, "Alexander Mikhalitsyn" <alex@amutable.com>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>, "Andy Lutomirski"
 <luto@amacapital.net>, "Arnd Bergmann" <arnd@arndb.de>, "Christian Brauner"
 <brauner@kernel.org>, "David Howells" <dhowells@redhat.com>, "Eric Biggers"
 <ebiggers@kernel.org>, "Giuseppe Scrivano" <giuseppe@scrivano.org>, "Hugh
 Dickins" <hughd@google.com>, "Jan Kara" <jack@suse.cz>, "Jeff Layton"
 <jlayton@kernel.org>, "Jonathan Corbet" <corbet@lwn.net>, "Josef Bacik"
 <josef@toxicpanda.com>, "Kees Cook" <kees@kernel.org>, "KP Singh"
 <kpsingh@kernel.org>, "Lennart Poettering" <lennart@poettering.net>, "Neal
 Gompa" <neal@gompa.dev>, "Oleg Nesterov" <oleg@redhat.com>, "Paul Moore"
 <paul@paul-moore.com>, "Pavel Tikhomirov" <ptikhomirov@virtuozzo.com>,
 "Serge Hallyn" <sergeh@kernel.org>, "Shuah Khan"
 <skhan@linuxfoundation.org>, "Zygmunt Krynicki"
 <zygmunt.krynicki@canonical.com>
Subject: Re: [RFC PATCH v7 00/26] userland: Userland containers
From: "Alexei Starovoitov" <alexei.starovoitov@gmail.com>
To: "Jarkko Sakkinen" <jarkko@kernel.org>, <linux-fsdevel@vger.kernel.org>
In-Reply-To: <20261122193539.3334213-1-jarkko@kernel.org>
References: <20261122193539.3334213-1-jarkko@kernel.org>
Content-Transfer-Encoding: 8bit
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Post: <mailto:containers@lists.linux.dev>
List-Help: <mailto:containers+help@lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
List-Owner: <mailto:containers+owner@lists.linux.dev>
Precedence: list
MIME-Version: 1.0

On Sun, Nov 22, 2026 at 11:35 AM Jarkko Sakkinen <jarkko@kernel.org> wrote:
> v6: https://lore.kernel.org/linux-fsdevel/20261122011809.2667684-1-jarkko@kernel.org/

v7 was sent 18 hours after v6. v6 got replies from the bots only.
v1 was +2559 lines. v7 is +5782.
All six findings of sashiko on v6 are still in v7.
None of the seven versions got a reply from the vfs or LSM maintainers.

The way you're spamming people you're only reducing chances of anything going in.


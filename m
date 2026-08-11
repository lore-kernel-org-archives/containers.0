Received: from mail-pj2-f4.google.com (mail-pj2-f4.google.com [74.125.227.132])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B1EAD43C7DB
	for <containers@lists.linux.dev>; Tue, 11 Aug 2026 10:49:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.132
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786445373; cv=none; b=ZKTFVTcQ0ozx36fp/0SAZqw5T/qiqV2DbkiFtmZgTM9+1zmsGH/tcEYXXshR8PxQA5Dji4VEEOpw56oKv5aKpYgMMRcQU+JWjjdxGi9wR7j+9wZ+5bNQUJGiWSX3gdmnwl59tcfWA0Yqh0EQUq9fVsrFhZ0Uei/eXw4v+l416rQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786445373; c=relaxed/simple;
	bh=ghS+Q8ddKbWmypXRks4ACpl90kL3VTsYQSivB8z4dzM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=DgD3t9csLLOvHZ0rcrBQfiQ7+FSoC9qWMvBRrIu2xP4mZUcJHE6qGoFXWT2LIY4KE8CRQRnner/kFxavEDiVr296jt+VAUf6PJHDkYrS3yEUBfGelWx9lQPAniSI7ex4myCC7byUwQ+OPIarGF0tvUEv/dqb8o6McnyPQ8D+p6g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Xt7Ec4CM; arc=none smtp.client-ip=74.125.227.132
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Xt7Ec4CM"
Received: by mail-pj2-f4.google.com with SMTP id 98e67ed59e1d1-3896ccc93b5so1205235a91.1
        for <containers@lists.linux.dev>; Tue, 11 Aug 2026 03:49:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1786445368; x=1787050168; darn=lists.linux.dev;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=ghS+Q8ddKbWmypXRks4ACpl90kL3VTsYQSivB8z4dzM=;
        b=Xt7Ec4CMmfw4qgUsmIcXCjkYrRvgmH55a9RCogZE/UFnZUBkwZreEHaZhDxs+HKUXk
         ofrDHZ8KmLhxUTg+R0Uu0uVlekUUFPEuBr8WGmCdD2nOtXv/9wA+uhTCefgwCudpLBrl
         NDMkO71imcxZVNbc7SuhCei4rbggTgim4weEhhmUOCDF9VR8QxCTyWBvbazZ5OfA1HGq
         nUS/WQ6HQwc2mwfLZuGo2g0m45Ep4HW1wUbwhPdDfQX7mYKBfzcXEsZMmCu9/a50eTUN
         XKbSQ7hfsaQwyBP8R6C6x6XNCXKy+y2MJEWzvM57xWYmA3Sqb3rT7IwBNyRngwT0SO/W
         NkDg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786445368; x=1787050168;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=ghS+Q8ddKbWmypXRks4ACpl90kL3VTsYQSivB8z4dzM=;
        b=JcyrArQPNqVamkvR/N7TC6Br8aw6S7KmxzEOZT7nQwlAOX9mrajWa7ozYubK93MHai
         ydenQrq9Q7nB8ZC3tkG4zGYgsUDUMInGMBceQEpY2/e3A1vunuy1eFCZiVUHGB+nBIGE
         qB1SibgTUSu/P27L9PZnUgSQ13MAgIEIw7Z9LQrtYpcGgXouRJJfzSyqTJnrqzoLtvF4
         ZfPrzu+Mr6kC97O6dI6BajBifyUhs/Q0TKPjPAfZuI7bys7DI1y/hgWmLroV72qkUzY0
         +6tZE7l2lzaBx1JsdWJUqZ9B/bKr4bpyYoG8x3gXBobuX2BqP/Yy14CM2NCsLznO6H81
         MUaA==
X-Forwarded-Encrypted: i=1; AHgh+RrlxVDajn4JDPutVbJmqXLgB2GIUnktNyBMmPdHLFg9kysvS5AwttwF9JEJXc9A3hsj9rqI26z9QmYb@lists.linux.dev
X-Gm-Message-State: AOJu0YzxQAjueOQ8OZZ/xZMjHYZvzk28fNjAGvUTGfL3MRKIuJ5YoJGM
	26H+iePN+fSXQQ2kr5qisXbo4lnlxifeLn6DB58l9Po5OKtiExi/7cuE+zGV2a8/OJPOzaVU9+z
	ITw==
X-Gm-Gg: AR+sD11n3VwqHdsXOHaQpLOQWPNS/OUbWFRlnhzKFzJv0PfEwDJyZWAvmQZYz+4eFRI
	7V87xT7CkJCSQ/xYW3DPl+866tS6VC4JlMv8LHSdo8l81d09SS+GlVmBFMph7LOSjXLKpKhABMj
	xYrqbtxLMWcKHNuVOpsSXT7UscTmY7nBrCtVTVZ7g50N72CCS+F9jvPKG0ZpitXfHBb5syARf3H
	epDbybDbuFOTUCInSJXv0M6d3kwtq+IJKlsQNGzqXFfVvBLjzKjNt9EM3eYemK2rF35gSwgBCRY
	KhVElE6WydKXNHGDfHIYGWMmYQQJVh91//JpSdJEhev0RTKIcXKg9FNzRRfsdOdMNb+h+jHKF15
	MxOJL5nkj5TtvbEOkJF2+JJXEVTndSkDFtpOj1o42KgzRieM+NigZFVx4a0UmeaFCkT2AWauBgC
	JHJN8OchbHwLVfbaVCbzLxLxi8FoRv9f3luYaKVHaO8i2ozQ/ypS09v7tgxCnW4tXpuy6zXUeeZ
	EYwR6la7FSbKmgDkQ==
X-Received: by 2002:a17:90b:3143:b0:381:5a08:6291 with SMTP id 98e67ed59e1d1-392ec747b05mr2307488a91.20.1786445368003;
        Tue, 11 Aug 2026 03:49:28 -0700 (PDT)
Received: from xiaomip5p-elish-armbian.. ([2408:8220:6b4b:bb0:3bc5:a2cf:f997:7a80])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-392d51e3467sm3436132a91.8.2026.08.11.03.49.24
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 11 Aug 2026 03:49:27 -0700 (PDT)
From: Gu Lingguang <liu83783@gmail.com>
To: Alexey Gladkov <legion@kernel.org>,
	Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	containers@lists.linux.dev,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Aleksa Sarai <cyphar@cyphar.com>,
	"Serge E . Hallyn" <serge@hallyn.com>,
	Gu Lingguang <liu83783@gmail.com>
Subject: Re: [RFC] mnt_already_visible(): should regular-file mountpoints participate in the visibility check?
Date: Tue, 11 Aug 2026 18:49:21 +0800
Message-ID: <20260811104921.8099-1-liu83783@gmail.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20260811-obsession-propeller-eiskalt-a2ca8b0a1017@brauner>
References: <20260811-obsession-propeller-eiskalt-a2ca8b0a1017@brauner>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Thanks to both of you for the replies.

@legion: The /proc/keys and /proc/interrupts case you raised is one
I missed, and it shows that a new mount can grant access that the
container's creators do not want to grant. I withdraw the suggestion.

@Brauner: you're right, and I apologize for the length. I'll keep
future questions to the bare minimum.

Thanks,
Gu Lingguang

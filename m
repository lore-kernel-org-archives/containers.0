Received: from mail-pl1-f176.google.com (mail-pl1-f176.google.com [209.85.214.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 442F172
	for <containers@lists.linux.dev>; Fri,  2 Jul 2021 17:40:51 +0000 (UTC)
Received: by mail-pl1-f176.google.com with SMTP id z4so5963202plg.8
        for <containers@lists.linux.dev>; Fri, 02 Jul 2021 10:40:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ycjp7IAqDr2sOnAy7FcDwlQNyrrs73BvoaVb1DqiHGQ=;
        b=hXCal/zMzcHOOkI6LKY9PJwrhZjek3Uq1Q8hFYTilZlPb1rFzm6fbNxp1zfgInmKlm
         LibPHj/kHN2YrKH/wvbI5ghwA2Nee0C7MlDjM0ZQLL76sU463eEtLN0ru0/XvM77sP5C
         llg11fZ9NUv+f6B/uoZtFg/6bcaIPI5zRSonE=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ycjp7IAqDr2sOnAy7FcDwlQNyrrs73BvoaVb1DqiHGQ=;
        b=E/UpMyT4SvFUV9irXHRKGMZC5YNRYsHASzoPAEfj9N8It4yeLmo7HYyydxlWf/Ox1B
         B3dZ7X58AVxejq9n6jDkNG7GvgNRNH/iYYksuaXXpDvRUgp3t9Fhl9hR1kZyAcHWMF8u
         tswVJkNvRLyOYkzsmLkGP549TTIIf+d+Mz1rLQZHTbEbJs9MaArbI+0YzQb5MbVXIF72
         2orppPjK+sykZhn/rY+VK5bhvfk8R7hUc5lua+G8Z6np67iOG4ODMd3j+XD+iKftaCY3
         fm0pz5yJqLkL6HqbjNsW/D3WmQ3SDPjg+QZmi8ed3a96RdjAZcsnB8gFA1422L26Ha7t
         hrBQ==
X-Gm-Message-State: AOAM531kzaTCOL28i/9QCKHWudgPWCcg0EIcq832eGov4S4dlzgt4LwW
	9c3r6nFinIjbJxmdwjDDKZjPBw==
X-Google-Smtp-Source: ABdhPJwMSoOsTEABHtrW7HqLlaxkNVRoZIIw7kxoTj6Qn0w7ATi2x4YP5nEMFYDBI56IJyRFWz68UQ==
X-Received: by 2002:a17:90a:a48b:: with SMTP id z11mr840698pjp.24.1625247650754;
        Fri, 02 Jul 2021 10:40:50 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id e29sm4400649pfm.0.2021.07.02.10.40.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 02 Jul 2021 10:40:49 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
To: Rodrigo Campos <rodrigo@kinvolk.io>,
	linux-kernel@vger.kernel.org,
	containers@lists.linux.dev,
	Will Drewry <wad@chromium.org>,
	Andy Lutomirski <luto@amacapital.net>
Cc: Kees Cook <keescook@chromium.org>,
	=?UTF-8?q?Mauricio=20V=C3=A1squez=20Bernal?= <mauricio@kinvolk.io>,
	Christian Brauner <christian.brauner@ubuntu.com>,
	Sargun Dhillon <sargun@sargun.me>,
	Alban Crequy <alban@kinvolk.io>
Subject: Re: [PATCH] Documentation: seccomp: Fix typo in user notification
Date: Fri,  2 Jul 2021 10:40:42 -0700
Message-Id: <162524764023.3795686.15431640935196466896.b4-ty@chromium.org>
X-Mailer: git-send-email 2.30.2
In-Reply-To: <20210702151927.263402-1-rodrigo@kinvolk.io>
References: <20210702151927.263402-1-rodrigo@kinvolk.io>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Fri, 2 Jul 2021 17:19:27 +0200, Rodrigo Campos wrote:
> The close on exec flag is O_CLOEXEC, not O_EXEC. This patch just fixes
> the typo.

Applied to for-next/seccomp, thanks!

[1/1] Documentation: seccomp: Fix typo in user notification
      https://git.kernel.org/kees/c/19d67694745c

-- 
Kees Cook


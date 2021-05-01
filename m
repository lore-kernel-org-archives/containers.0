Received: from mail-qv1-f44.google.com (mail-qv1-f44.google.com [209.85.219.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C19612F80
	for <containers@lists.linux.dev>; Sat,  1 May 2021 14:03:22 +0000 (UTC)
Received: by mail-qv1-f44.google.com with SMTP id jm10so470769qvb.5
        for <containers@lists.linux.dev>; Sat, 01 May 2021 07:03:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linuxfoundation.org; s=google;
        h=date:from:to:subject:message-id:mime-version:content-disposition;
        bh=pg3iHnTXXUCsFLfR2vg7tigFfdJHPwv5EBjO0+sbnic=;
        b=XbzLYKXeerYRWTXdc6HfXBGo0R5bP7WV32tweDKLKCpouVZiiVOmzs341Nz2r/cADs
         vGJ5yX22UpCwhDAiRVrpEEyBP6zTyWwg6xpGbl8HRgwWYCeNO66QSy43Iss8wjthfe6Y
         qPDX8l3q8635+z3gfTN6k92Uq3hRpRigPFfbs=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:subject:message-id:mime-version
         :content-disposition;
        bh=pg3iHnTXXUCsFLfR2vg7tigFfdJHPwv5EBjO0+sbnic=;
        b=ARPApzAjGaaYJcq31Oh7GMIy4Lx3B3ToY/rnxH2iZ6oeNEYocLN/XDAA++BoL3VvTn
         dHIn653Vc/rF3g1AkUyoQejNFdv40dwplU2j7eonyD+88FLt3jLY64/n6PsBqTFngqTK
         p5GvDqtU5wlMTK3GL+3JccmuT/BOa2UsEoJLxNExpTjjiPnoYwh2BGtvlVDwHSskuYKz
         kpd/s/lVlYxoxNvACA1+eOjNd5fAQTqr91F5OhrD6fjpZOkdLfdVObViN0l4kkBTLk+M
         daw2RedRdoS6E6tLs93DeV1A+gpOt8CEV1uCEocGhI7W4vAEAg5XpQSVVyQreTkkzVa0
         iE6g==
X-Gm-Message-State: AOAM531UgaSshdaiWcLWHKYFCWpx+IQaHnvTZMPsPnYpWUPvMQiFdqv1
	ymlYuLaG+k0nr4GOo0yNYTF6LZ+BxC6CZr2b
X-Google-Smtp-Source: ABdhPJzJowazdPkyYVmbUGMQEUso2hj63LQGX0i5ClMFulr6VX70j1N8vw6Y46QNU39QnfqePpOz0g==
X-Received: by 2002:a05:6214:583:: with SMTP id bx3mr521589qvb.38.1619877801531;
        Sat, 01 May 2021 07:03:21 -0700 (PDT)
Received: from nitro.local ([89.36.78.230])
        by smtp.gmail.com with ESMTPSA id h8sm4198338qkj.4.2021.05.01.07.03.20
        for <containers@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 01 May 2021 07:03:21 -0700 (PDT)
Date: Sat, 1 May 2021 10:03:19 -0400
From: Konstantin Ryabitsev <konstantin@linuxfoundation.org>
To: containers@lists.linux.dev
Subject: The containers list has moved!
Message-ID: <20210501140319.aohzfxd7nao7sjev@nitro.local>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Hello, everyone:

As you have been previously warned, the containers list has moved to its new
home. From now on, please send all messages to:

    containers@lists.linux.dev

The old address is still functioning, but it will send back an auto-responder
message saying that the list has moved and that all messages should be resent.

If you notice any trouble with the new list, please let me know.

Regards,
-K

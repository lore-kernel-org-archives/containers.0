Received: from mail-vk1-f180.google.com (mail-vk1-f180.google.com [209.85.221.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9D6E57C
	for <containers@lists.linux.dev>; Mon, 28 Feb 2022 15:06:50 +0000 (UTC)
Received: by mail-vk1-f180.google.com with SMTP id b64so1959132vkf.7
        for <containers@lists.linux.dev>; Mon, 28 Feb 2022 07:06:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=szeredi.hu; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jiqKta+C/bUAijQgVs2pIwZxEquJxCrRrkx40wt5xeU=;
        b=jrZ7QG8cvbuAWbySWWqcPRl1HzBxXrPIQi88Qwxn9KEns4B4V6BG/WCFVt2TODG2Ek
         mVVcRUWT7BUAL5BAyusW6Vh4apN5Ewv3KR/Aq+pMkgfcel1DXFU8JWDqrvlCEpRo5wt5
         tALdoK1ujT5pztZcBl+qe2p7Xd+6FhJuFYLw0=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=jiqKta+C/bUAijQgVs2pIwZxEquJxCrRrkx40wt5xeU=;
        b=zHRpPQZLTF1F+w/SDMKAnDTkps6KU3J425n9w3ac6YvdVIXSlzZPFXshw8nQD6Dkvu
         uFTOnI+6tVwkrJSKFbMvFUGsZvNJtuBTCvjhzPdjNsenwrg6VWRCbuq6SeF6sYawNdSa
         85A2tnxmVv8HcK2MSgBlwxs40m7CixD5rJx0V/Wyfv4yJ3i/OhuOTkdfroY8yjl1suiK
         DfHS8Je9g0tixRRjBX6YMpQD3Fqei7XMocO4mECankRjnvvtVpPvIEKKx2qModWd4XUU
         lSmnfoxXyBc/PjM5CB84G2KDe5cJm/0szeZbs/QUd8rqgvNDxY2OE1pcCQ/c04u+VYZo
         QEZg==
X-Gm-Message-State: AOAM532iF8g4wcVwdPrNoWRVpFhXxP0qgZHtHcyLn7EjRy/4aH7BpIqt
	TxeSlBq5aSQ7LxBzrqjRZVTqJE4rzgPI14Nzwokzkw==
X-Google-Smtp-Source: ABdhPJwG4oeunZtfTAqFSdPSvXQ/EGO74OOSjPwKybQKY955Q+Lm+yXaJNDZXx6QkmGxjo5MfMxF2Uv2x7n3YyUuw60=
X-Received: by 2002:a05:6122:2213:b0:31b:76c3:16df with SMTP id
 bb19-20020a056122221300b0031b76c316dfmr7894044vkb.31.1646060809331; Mon, 28
 Feb 2022 07:06:49 -0800 (PST)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20220228113910.1727819-1-amir73il@gmail.com> <20220228113910.1727819-5-amir73il@gmail.com>
In-Reply-To: <20220228113910.1727819-5-amir73il@gmail.com>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 28 Feb 2022 16:06:38 +0100
Message-ID: <CAJfpegvZefGp9NChm_69Km0FgpxwUs+og-uc2mpMAbH6mZ2azQ@mail.gmail.com>
Subject: Re: [PATCH v2 4/6] fs: report per-mount io stats
To: Amir Goldstein <amir73il@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, overlayfs <linux-unionfs@vger.kernel.org>, 
	containers@lists.linux.dev, linux-fsdevel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Mon, 28 Feb 2022 at 12:39, Amir Goldstein <amir73il@gmail.com> wrote:
>
> Show optional collected per-mount io stats in /proc/<pid>/mountstats
> for filesystems that do not implement their own show_stats() method
> and opted-in to generic per-mount stats with FS_MOUNT_STATS flag.

This would allow some filesystems to report per-mount I/O stats, while
leaving CIFS and NFS reporting a different set of per-sb stats.  This
doesn't sound very clean.

There was an effort to create saner and more efficient interfaces for
per-mount info.  IMO this should be part of that effort instead of
overloading the old interface.

Thanks,
Miklos

Received: from mail-pj1-f49.google.com (mail-pj1-f49.google.com [209.85.216.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 938CF2FB4
	for <containers@lists.linux.dev>; Thu, 27 May 2021 18:37:49 +0000 (UTC)
Received: by mail-pj1-f49.google.com with SMTP id lx17-20020a17090b4b11b029015f3b32b8dbso2978245pjb.0
        for <containers@lists.linux.dev>; Thu, 27 May 2021 11:37:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=wo61vuP8itAsZbt2t1dPCmKidBoeF2uLqMWDtAxwKzg=;
        b=Pyn+69PDHkODviT5Ornz6p2X8/CXaFeyRyt/FTNk7L408ugYRNR/1y341aGCjilncc
         WdZLfizUfUDIAIe77e8hMEQEhCy//CgKsmcWhn7ThIX8qR+azD+RqTUMTHynK2NS0qhe
         w2mr/gmsaVNv3zMjGs/EGpImpmVp/SfyZvPLQ=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to;
        bh=wo61vuP8itAsZbt2t1dPCmKidBoeF2uLqMWDtAxwKzg=;
        b=uoAkY9M1Jnojow4MjTNXoTUviaZRnGv1a5uoKQIh4t59ot86/o4AanE8HKvBm4mkv6
         8pB2/pvalhfozFx+PYzrvFRUMmzZzn42nXB58V90cNgRL6AsNEz8oo4CPLjtZ/l+SEX7
         EkcsTToOQ1s3KyZYT3BnxO2u//trrGHw+q6HPwfflIysPwICOKWF2bfwe971DzAgtvqz
         oayD8AWuPcEbO+2KhowUlUEnIxBXu2ZESz871aD/0JMZWDq2CODbfzpKB1hqGML9Y8vb
         NXXEQr1pE6FCUJ8TeOXXxbxdELkepqtDoF+fqf7lr8E9nxwcYJG0hgT3H5d8t/fx/C4t
         fGxQ==
X-Gm-Message-State: AOAM533ZjQj0DWfA0Jiu75thDEp3F0aihPt1sli6sDU2UA7P1qH5SzO1
	gzGOe1ucXuyNJggQrsFwB2fMaw==
X-Google-Smtp-Source: ABdhPJx7gUhC+H++qqo1KLIfawtDGiTJkGG2lpEYBgdm1042nL2trg7RmeYBjaIl/Zl20wf2FOmbTA==
X-Received: by 2002:a17:902:bf46:b029:ee:b949:bd0 with SMTP id u6-20020a170902bf46b02900eeb9490bd0mr4383042pls.14.1622140669177;
        Thu, 27 May 2021 11:37:49 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id h3sm2296385pgp.10.2021.05.27.11.37.48
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 27 May 2021 11:37:48 -0700 (PDT)
Date: Thu, 27 May 2021 11:37:47 -0700
From: Kees Cook <keescook@chromium.org>
To: Rodrigo Campos <rodrigo@kinvolk.io>
Cc: LKML <linux-kernel@vger.kernel.org>, Sargun Dhillon <sargun@sargun.me>,
	containers@lists.linux.dev, Tycho Andersen <tycho@tycho.pizza>,
	Mauricio =?iso-8859-1?Q?V=E1squez?= Bernal <mauricio@kinvolk.io>,
	Giuseppe Scrivano <gscrivan@redhat.com>,
	Christian Brauner <christian.brauner@ubuntu.com>,
	=?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@linux.microsoft.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Will Drewry <wad@chromium.org>
Subject: Re: [PATCH] selftests/seccomp: More closely track fds being assigned
Message-ID: <202105271137.251E14ACB2@keescook>
References: <20210527032948.3730953-1-keescook@chromium.org>
 <CACaBj2atO=2aAyK+BO5MPS0B3CQNwc98CSHiuy8X2wvkdvJNDQ@mail.gmail.com>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACaBj2atO=2aAyK+BO5MPS0B3CQNwc98CSHiuy8X2wvkdvJNDQ@mail.gmail.com>

On Thu, May 27, 2021 at 02:45:26PM +0200, Rodrigo Campos wrote:
> On Thu, May 27, 2021 at 5:29 AM Kees Cook <keescook@chromium.org> wrote:
> >
> > Since the open fds might not always start at "4" (especially when
> > running under kselftest, etc), start counting from the first assigned
> > fd, rather than using the more permissive EXPECT_GE(fd, 0).
> >
> > Signed-off-by: Kees Cook <keescook@chromium.org>
> 
> Nice cleanup, thanks! Just in case, tested it here, works fine. Feel
> free to add:
> 
> Reviewed-by: Rodrigo Campos <rodrigo@kinvolk.io>

Thanks!

> I can improve the selftest to test the new addfd flag we just added
> also in combination existing flags (like setting the fd number to
> use), and maybe also split the big chunk test, if you think that is
> valuable.

Yeah, I was pondering splitting the test up, but I think it's okay how
it is for now.

-- 
Kees Cook

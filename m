Received: from mail-yb1-f180.google.com (mail-yb1-f180.google.com [209.85.219.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6E21E13B58A
	for <containers@lists.linux.dev>; Thu, 13 Jun 2024 20:43:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.219.180
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718311400; cv=none; b=VXZBfRN4tvW7FrwY7dYp8/Tuwn6uieWk682RWz2QL1GXdNme/DDQwicN/i062XYLyKmKEY86kiJ8XZze9P8MN3Bb0Ne1uenrwg2csHGnbMhWqT+HrzfMQl2aMvBArm09zjoiFhI85Li2OT7hmYbMijTDCCKmEzu/HACaQXFX2dA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718311400; c=relaxed/simple;
	bh=Te1wWeTYuhWG0UJJRZ0nQ9Ccy7EzdVqqwIlRrujyH3k=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=hCZZReqcKXRkyncHlSc6MWZmHVAsZfH5zlcoHxPGFYBS44OjdEvGURWnFkZZU+tMItJw9looBgDsp3VfBpKzErChNR/TZlp6SeIq5fXfZYjPcsB61O/VyMFCRCaAIqI6LIz7LpDSTPBI2Pv7eWcGhBBApTElEhGcwzaaSa4SpLY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=paul-moore.com; spf=pass smtp.mailfrom=paul-moore.com; dkim=pass (2048-bit key) header.d=paul-moore.com header.i=@paul-moore.com header.b=dw0vhis0; arc=none smtp.client-ip=209.85.219.180
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=paul-moore.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=paul-moore.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=paul-moore.com header.i=@paul-moore.com header.b="dw0vhis0"
Received: by mail-yb1-f180.google.com with SMTP id 3f1490d57ef6-dff02b8a956so1352719276.1
        for <containers@lists.linux.dev>; Thu, 13 Jun 2024 13:43:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=paul-moore.com; s=google; t=1718311394; x=1718916194; darn=lists.linux.dev;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Mbp06UNvP6AGs/AzZYfCY2RlFHeTWL3VjFq/M7RiWuQ=;
        b=dw0vhis06gckoq3Ro5hGn3LxsZ8Fryc1qydg8km9hF92GlYdqvZw5hZJzZGDBLIQGK
         CsaoDDcOasxknZX0dmAsxz/pMxm637Pbx1m1bCspaFmRP3oU38fcTF2O7ucbA0I5cbeH
         6gnzoLM5hz00AyGmtl+PxfGLgcI3/5gue9vh59Uvabx0hvc8lnWhhjyZyR4z3mnZG4g7
         uINHAoGAxeBoL6OvPjULtDJ0cDud6QnD60MtDhdlZenlf8BMz9wWUVqs6tkLgIWzQmda
         Mb8SBHRcgpuvrE7cybhl9iGf1PB0gmhOXOiCNlyoFmBLNk+aB5SX0GwHXTf6kcxr0fdX
         XbrQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1718311394; x=1718916194;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=Mbp06UNvP6AGs/AzZYfCY2RlFHeTWL3VjFq/M7RiWuQ=;
        b=H36t01LjdrTNAkHOFSAGcOh74nw4/W7n7KO2g7LiCsoXHKj2xSEdSv+oi3HD2w5/FC
         pSn2p5b/6zoXdaZ5ZJrxp9YTv2HADaaaTWUkfTAouCwn2jAya+Mjmf28k6jRTAK2yoFJ
         MCGHlQMaKLiRpo8Ssr/jc0qPK6J8NP18LQUL8aJ8kuD2ujqRuElNouIaYEZSgQ/kKauE
         CKeS6jIf06y4702GgUNbiIg8UVZaHHgfTpiyZITOCo+UeknpAEuqLRLmkYmTPGxGcAjA
         VmezSfnFy+1WroLjjw/xUD3fcXCVTzXhmyDoKVJuGvFqtJemc0AkJflMVUi/8o4ivuwB
         Egjw==
X-Forwarded-Encrypted: i=1; AJvYcCWqSVbLWYoJqrW062fR/MOIhdZCtwGgE7IBlIpdkzWg9/+ffimcFHSNToaePQzQ/AvjCFoC2pJzNP+xPIXg2EOXSDxTGF3xV3U2JQ==
X-Gm-Message-State: AOJu0YyPqEso4D14bjHsvHQWzqBdNsjeMRRKhM4SLSgs60JXM15ODsa4
	p3RViXoDbBeAXD2D99irQDz48K+fZTfN6HCxqJbnduxwbS8NcB0UjO13OonU17/JlNlYe4hIVpP
	4DwMhyL+uQKZk0/s3T6GtSuvdXCfyladV5z3Q
X-Google-Smtp-Source: AGHT+IG0WhxM6z6YdDtEWCi+I5IKFVVK+KMGdEQEjK8s3DDuXT3JscqlC3UvTHCxO6S8YW/rHWD2Pox3VJGxEor1JBc=
X-Received: by 2002:a25:b327:0:b0:dfe:653:3de0 with SMTP id
 3f1490d57ef6-dff154f9c91mr601718276.63.1718311394391; Thu, 13 Jun 2024
 13:43:14 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20240609104355.442002-1-jcalmels@3xx0.net> <20240609104355.442002-5-jcalmels@3xx0.net>
 <CAHC9VhT5XWbhoY2Nw5jQz4GxpDriUdHw=1YsQ4xLVUtSnFxciA@mail.gmail.com>
 <z2bgjrzeq7crqx24chdbxnaanuhczbjnq6da3xw6al6omjj5xz@mqbzzzfva5sw>
 <887a3658-2d8d-4f9e-98f2-27124bb6f8e6@canonical.com> <CAHC9VhQFNPJTOct5rUv3HT6Z2S20mYdW75seiG8no5=fZd7JjA@mail.gmail.com>
 <uuvwcdsy7o4ulmrdzwffr6uywfacmlkjrontmjdj44luantpok@dtatxaa6tzyv>
 <CAHC9VhRnthf8+KgfuzFHXWEAc9RShDO0G_g0kc1OJ-UTih1ywg@mail.gmail.com>
 <rgzhcsblub7wedm734n56cw2qf6czjb4jgck6l5miur6odhovo@n5tgrco74zce>
 <CAHC9VhRGJTND25MFk4gR-FGxoLhMmgUrMpz_YoMFOwL6kr28zQ@mail.gmail.com> <ba8d88c8-a251-4c1f-8653-1082b0a101dd@canonical.com>
In-Reply-To: <ba8d88c8-a251-4c1f-8653-1082b0a101dd@canonical.com>
From: Paul Moore <paul@paul-moore.com>
Date: Thu, 13 Jun 2024 16:43:03 -0400
Message-ID: <CAHC9VhTfXGeSkDxCaHRWRJjc+4DBorHOrqhrw8BzWhKD9SG39Q@mail.gmail.com>
Subject: Re: [PATCH v2 4/4] bpf,lsm: Allow editing capabilities in BPF-LSM hooks
To: John Johansen <john.johansen@canonical.com>
Cc: Jonathan Calmels <jcalmels@3xx0.net>, brauner@kernel.org, ebiederm@xmission.com, 
	Jonathan Corbet <corbet@lwn.net>, James Morris <jmorris@namei.org>, "Serge E. Hallyn" <serge@hallyn.com>, 
	KP Singh <kpsingh@kernel.org>, Matt Bobrowski <mattbobrowski@google.com>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Andrii Nakryiko <andrii@kernel.org>, Martin KaFai Lau <martin.lau@linux.dev>, 
	Eduard Zingerman <eddyz87@gmail.com>, Song Liu <song@kernel.org>, 
	Yonghong Song <yonghong.song@linux.dev>, John Fastabend <john.fastabend@gmail.com>, 
	Stanislav Fomichev <sdf@google.com>, Hao Luo <haoluo@google.com>, Jiri Olsa <jolsa@kernel.org>, 
	Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <kees@kernel.org>, 
	Joel Granados <j.granados@samsung.com>, David Howells <dhowells@redhat.com>, 
	Jarkko Sakkinen <jarkko@kernel.org>, Stephen Smalley <stephen.smalley.work@gmail.com>, 
	Ondrej Mosnacek <omosnace@redhat.com>, Mykola Lysenko <mykolal@fb.com>, Shuah Khan <shuah@kernel.org>, 
	containers@lists.linux.dev, linux-kernel@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, linux-doc@vger.kernel.org, 
	linux-security-module@vger.kernel.org, bpf@vger.kernel.org, 
	apparmor@lists.ubuntu.com, keyrings@vger.kernel.org, selinux@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 12, 2024 at 11:54=E2=80=AFPM John Johansen
<john.johansen@canonical.com> wrote:
> On 6/12/24 10:29, Paul Moore wrote:
> > On Wed, Jun 12, 2024 at 4:15=E2=80=AFAM Jonathan Calmels <jcalmels@3xx0=
.net> wrote:
> >> On Tue, Jun 11, 2024 at 06:38:31PM GMT, Paul Moore wrote:
> >>> On Tue, Jun 11, 2024 at 6:15=E2=80=AFPM Jonathan Calmels <jcalmels@3x=
x0.net> wrote:
> >
> > ...
> >
> >>>> Arguably, if we do want fine-grained userns policies, we need LSMs t=
o
> >>>> influence the userns capset at some point.
> >>>
> >>> One could always use, or develop, a LSM that offers additional
> >>> controls around exercising capabilities.  There are currently four
> >>> in-tree LSMs, including the capabilities LSM, which supply a
> >>> security_capable() hook that is used by the capability-based access
> >>> controls in the kernel; all of these hook implementations work
> >>> together within the LSM framework and provide an additional level of
> >>> control/granularity beyond the existing capabilities.
> >>
> >> Right, but the idea was to have a simple and easy way to reuse/trigger
> >> as much of the commoncap one as possible from BPF. If we're saying we
> >> need to reimplement and/or use a whole new framework, then there is
> >> little value.
> >
> > I can appreciate how allowing direct manipulation of capability bits
> > from a BPF LSM looks attractive, but my hope is that our discussion
> > here revealed that as you look deeper into making it work there are a
> > number of pitfalls which prevent this from being a safe option for
> > generalized systems.
> >
> >> TBH, I don't feel strongly about this, which is why it is absent from
> >> v1. However, as John pointed out, we should at least be able to modify
> >> the blob if we want flexible userns caps policies down the road.
> >
> > As discussed in this thread, there are existing ways to provide fine
> > grained control over exercising capabilities that can be safely used
> > within the LSM framework.  I don't want to speak to what John is
> > envisioning, but he should be aware of these mechanisms, and if I
> > recall he did voice a level of concern about the same worries I
> > mentioned.
> >
>
> sorry, I should have been more clear. I envision LSMs being able to
> update their own state in the userns hook.

Ah, okay, yes, that seems reasonable; although like any other change,
until we have an in-tree user we should just leave it as-is.

--=20
paul-moore.com

Received: from mail-wr1-f49.google.com (mail-wr1-f49.google.com [209.85.221.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 241241106
	for <containers@lists.linux.dev>; Sat, 14 Oct 2023 03:41:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=bytedance.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=bytedance.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=bytedance.com header.i=@bytedance.com header.b="f+ec0tNJ"
Received: by mail-wr1-f49.google.com with SMTP id ffacd0b85a97d-3247cefa13aso2481534f8f.1
        for <containers@lists.linux.dev>; Fri, 13 Oct 2023 20:41:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=bytedance.com; s=google; t=1697254877; x=1697859677; darn=lists.linux.dev;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=8+uqdmO4xgns3ugpSGvOEmhx6xIg/OI7rgx8ycNmbLk=;
        b=f+ec0tNJEhVpqaGK/fnUY2Nh3qMLSxSzGh4wSkgrAsfvAAyLugIN16Uh4RVq0Sb6rA
         XHPJZq0+YRMwl5Vc1m8AYbWNK5Ded9ZJoAzbgiFg9oCe0AeuSEiD+PAbWK8k+GVEdPeT
         vJ4r5j0BoyTX5BNH5itkzKbEquWYw7qelM1steB4JT17As4LgtT6Td31IQA0SZtunt4T
         p3gi4FjfYSgen4ta8JZYSarDuIdNH7liZa0kM9GRLBFNcL84wI9oev/rggKPFzSFkRcR
         J8x5IXzsva076KFA64MMdd9IWzfbkQgTficXJ0N/ZGjYkrSB9UWtWM/DWTMAZ+stqg9h
         ASCQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1697254877; x=1697859677;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=8+uqdmO4xgns3ugpSGvOEmhx6xIg/OI7rgx8ycNmbLk=;
        b=DhCknN89aEfVPHdAZaqs9VYFyk0FwHy2lhklH4vviJmHOYhvy0S4tB2x8dJTyjejfs
         /SBzCTNkHJWt+j4qXRtcM+hE5V4sdppidW5SAwddjPOyLZ7vZqSRsW5vu+xINcBp+AuU
         melI8VnncQVjXuh9taNuQdPOGX7ycXraoDOxnJqVLlB3r9n+a3ZMWm3YtZgn9Xnp69i2
         ILK5CPfr6DCjgRviDm398Dl2pkMPoBqNYmK8UwGJBJRTHuCBhuvfi9nT9DiSFpl8UL2H
         Tw9cgCmjRxxaB0yxtlbWSzMXsmQMwJ8Vsa+gNq/Xn5JIpwPbnaJxD6GQ/2KIBPPJxwXE
         yBxQ==
X-Gm-Message-State: AOJu0Yw5vkhUBAImjhEyI0Oc5T0B8aBtt3Bh8YcVhsRHyue3u/naJWSz
	a2eTkXIlmHkFcazzYioj5JCJhtTYNOWrLm5cjj6s0A==
X-Google-Smtp-Source: AGHT+IE7iLanycP/oqIhjHkrP56/fLQX49HZv8wbRAs004f3GzJmu2RKZ2sKkYWjuCblXh4FuZwT4KqsBRbMfm2LvT0=
X-Received: by 2002:adf:a4da:0:b0:32d:7615:372b with SMTP id
 h26-20020adfa4da000000b0032d7615372bmr8604025wrb.12.1697254877240; Fri, 13
 Oct 2023 20:41:17 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20231011065446.53034-1-cuiyunhui@bytedance.com>
 <87sf6gcyb3.fsf@email.froward.int.ebiederm.org> <CAEEQ3wm8oE1dXo7AuU3gY90oF_G21OqNZwnkqhhd1-_j4wWbYQ@mail.gmail.com>
 <87r0lyad40.fsf@email.froward.int.ebiederm.org>
In-Reply-To: <87r0lyad40.fsf@email.froward.int.ebiederm.org>
From: yunhui cui <cuiyunhui@bytedance.com>
Date: Sat, 14 Oct 2023 11:41:06 +0800
Message-ID: <CAEEQ3wmerA8p2qpEAn9pGW5BW35777VFwabusyFTAEyaf-0JPg@mail.gmail.com>
Subject: Re: [External] Re: [PATCH] pid_ns: support pidns switching between sibling
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: akpm@linux-foundation.org, keescook@chromium.org, brauner@kernel.org, 
	jeffxu@google.com, frederic@kernel.org, mcgrof@kernel.org, cyphar@cyphar.com, 
	rongtao@cestc.cn, linux-kernel@vger.kernel.org, 
	Linux Containers <containers@lists.linux.dev>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Eric=EF=BC=8C

On Fri, Oct 13, 2023 at 9:04=E2=80=AFPM Eric W. Biederman <ebiederm@xmissio=
n.com> wrote:
>
> yunhui cui <cuiyunhui@bytedance.com> writes:
>
> > Hi Eric,
> >
> > On Thu, Oct 12, 2023 at 11:31=E2=80=AFAM Eric W. Biederman
> > <ebiederm@xmission.com> wrote:
> >>
> >> The check you are deleting is what verifies the pid namespaces you are
> >> attempting to change pid_ns_for_children to is a member of the tasks
> >> current pid namespace (aka task_active_pid_ns).
> >>
> >>
> >> There is a perfectly good comment describing why what you are attempti=
ng
> >> to do is unsupportable.
> >>
> >>         /*
> >>          * Only allow entering the current active pid namespace
> >>          * or a child of the current active pid namespace.
> >>          *
> >>          * This is required for fork to return a usable pid value and
> >>          * this maintains the property that processes and their
> >>          * children can not escape their current pid namespace.
> >>          */
> >>
> >>
> >> If you pick a pid namespace that does not meet the restrictions you ar=
e
> >> removing the pid of the new child can not be mapped into the pid
> >> namespace of the parent that called setns.
> >>
> >> AKA the following code can not work.
> >>
> >> pid =3D fork();
> >> if (!pid) {
> >>         /* child */
> >>         do_something();
> >>         _exit(0);
> >> }
> >> waitpid(pid);
> >
> > Sorry, I don't understand what you mean here.
>
> What I mean is that if your simple patch was adopted,
> then the classic way of controlling a fork would fail.
>
>         pid =3D fork()
>         ^--------------- Would return 0 for both parent and child
>         ^--------------- Look at pid_nr_ns to understand.
>         if (!pid() {
>                 /* child */
>                 do_something();
>                 _exit(0);
>         }
>         waitpid(pid);

okay, The reason here is that pid_nr_ns has no pid in the current
pidns of the child process, and returns 0.
Can this also support sibling traversal? If so, it means that the
process also has a pid in its sibling's pidns.


>
> For your use case there are more serious problems as well.  The entire
> process hierarchy built would be incorrect.   Which means children
> signaling parents when they exit would be incorrect, and that parents
> would not be able to wait on their children.

Therefore, support for slibing pidns must be added to the entire logic of p=
idns.
Do you have any plans to support this, or what are the good reasons
for not supporting it?

Thanks,
Yunhui

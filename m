From: Krzysztof Taraszka <krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>
Subject: Re: how to do not allow to mount /cgroup inside container?
Date: Tue, 25 Aug 2009 22:12:05 +0200
Message-ID: <ac1c4bf20908251312w11ac752vb9298beae15f6536@mail.gmail.com>
References: <ac1c4bf20908250517j43d49f9fv1b5d6d5beae8aa@mail.gmail.com>
	<4A93DD67.5030905@free.fr> <20090825140537.GA19644@us.ibm.com>
	<ac1c4bf20908250743t9c30c27ud3ff649003465334@mail.gmail.com>
	<20090825174509.GA26679@us.ibm.com>
Reply-To: kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090825174509.GA26679-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

2009/8/25 Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> Quoting Krzysztof Taraszka (krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org):
> > 2009/8/25 Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> >
> > > Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> > > > Krzysztof Taraszka wrote:
> > > >> Hi,
> > > >>
> > > >> I was looking for possibility to secure lxc container to do not
> allow
> > > 'root
> > > >> container user'  from changing limits from cgroup. Right now without
> > > STACK64
> > > >> or SELinux he can do this easily.
> > > >> I read the
> > >
> http://www.ibm.com/developerworks/linux/library/l-lxc-security/cookbook
> > > >> and decided to use STACK64 kernel mechanism.
> > > >> Well... mounting cgroup inside container fails (great!, i am looked
> for
> > > that
> > > >> ;)) but networking fails too (interface bring up, sshd bring up,
> > > connection
> > > >> beetween host and container is, but 'mtr', 'ping' even 'apt-get
> update'
> > > >> fails and I do not know why). I secure my container exactly like in
> the
> > > >> cookbook.
> > >
> > > Yeah, smack's use of cipso can make things tricky, and it's possible
> things
> > > have changed a bit recently.  Although I'm currently running smack in
> my
> > > everyday s390 kernel to test checkpointing of its labels, and
> networking
> > > is working fine.
> >
> >
> > > Can you give me a few details - what distro, smack policy, and precise
> > > kernel
> > > version are you using, for starters?
> > >
> >
> > debian lenny amd64,
> > kernel 2.6.30.5
> > lxc-tools from git
> >
> > lxc1amd64:~# cat /etc/smackaccesses
> > debian _ rwa
> > _ debian rwa
> > _ host rwax
> > host _ rwax
>
> Ok, I think what you want to do is use /smack/netlabel as shown around line
> 425 in linux-2.6/Documentation/Smack.txt.  I haven't played with it yet,
> but will tomorrow if you don't get a chance.  So basically I think you
> should
> be able to do:
>
> echo 127.0.0.1 -CIPSO > /smack/netlabel
> echo 0.0.0.0/0 @      > /smack/netlabel
>
> to open up the network.
>
> Does that work?
>

Yep :))
Works.
Anyway - are you going to update your cookbook on the ibm webpage?

-- 
Krzysztof Taraszka

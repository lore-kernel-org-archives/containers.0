From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [DRAFT] Container mini-summit notes v0.01
Date: Mon, 10 Sep 2007 10:09:58 -0600
Message-ID: <m1642iqz6x.fsf@ebiederm.dsl.xmission.com>
References: <46DE9E1C.6010309@fr.ibm.com>
	<20070905135357.GE1403@sergelap.austin.ibm.com>
	<6599ad830709050700y278d653eu371375c2fc107ef@mail.gmail.com>
	<20070905143808.GG1403@sergelap.austin.ibm.com>
	<46DF35DA.1090102@cs.columbia.edu>
	<20070905235828.GA32475@sergelap.austin.ibm.com>
	<46DFBE60.6030404@fr.ibm.com>
	<20070906153243.GA15436@sergelap.austin.ibm.com>
	<m1wsv0x5sv.fsf@ebiederm.dsl.xmission.com>
	<20070910141834.GA5866@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070910141834.GA5866-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org> (Serge
	E. Hallyn's message of "Mon, 10 Sep 2007 09:18:34 -0500")
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
Cc: Kir Kolyshkin <kir-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Masahiko Takahashi <masahiko-3NddpPZAyC0@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> Sorry, I was focusing on the virtual server needs.
>
> devpts is it's own fs so I was fully expecting to make it mountable
> multiple times so a container can have it's own /dev/pts/0.  So what
> other virtual devices would we want to be able to rec-reate for a
> migrated application?  (I wonder (a) what gregkh will say about having
> a device namespace, and (b) what the sysfs implications will be)

Depends.  There are things like the loop device that could be interesting.
There may be some others.  I haven't looked at it enough detail to get
beyond the fact that in some sense it isn't just limited to pts devices.

A multimount devpts is interesting though.

Eric

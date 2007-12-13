From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 9/9] signal: Ignore signals sent to the pid namespace
	init
Date: Thu, 13 Dec 2007 11:33:10 -0700
Message-ID: <m13au6savt.fsf@ebiederm.dsl.xmission.com>
References: <m13au8ytos.fsf@ebiederm.dsl.xmission.com>
	<m1y7c0xezt.fsf@ebiederm.dsl.xmission.com>
	<m1tzmoxexb.fsf_-_@ebiederm.dsl.xmission.com>
	<m1prxcxeum.fsf_-_@ebiederm.dsl.xmission.com>
	<m1lk80xeps.fsf_-_@ebiederm.dsl.xmission.com>
	<m1hcioxenh.fsf_-_@ebiederm.dsl.xmission.com>
	<m1d4tcxelu.fsf_-_@ebiederm.dsl.xmission.com>
	<m18x40xeg6.fsf_-_@ebiederm.dsl.xmission.com>
	<m13au8xe8m.fsf_-_@ebiederm.dsl.xmission.com>
	<m1y7c0vzm4.fsf_-_@ebiederm.dsl.xmission.com>
	<20071213162811.GC219@tv-sign.ru>
	<m1aboesbnu.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1aboesbnu.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org> (Eric W. Biederman's
	message of "Thu, 13 Dec 2007 11:16:21 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) writes:
>
> Yes.  If we are not in process context (in_interrupt) we do infer
> the sender incorrectly.  Duh.  I saw something in earlier patches
> people had posted didn't understand it, and didn't get an answer
> when I asked about it. 

Grr. Rather I didn't see a reply when I asked about it.  I just
spotted Suka's old reply telling me it was to attempt to prevent
init from getting sigio.    Clearly I have a big fat blind spot
here you could drive a truck through.

Kernel generated signals are a pain because they are neither fish nor
fowl. They are sent privileged, but we don't necessarily want to give
them all curtsies and deliver them.  Grr.

Eric

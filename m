From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 1/2] signals: kill(-1) should only signal processes in the
	same namespace
Date: Thu, 17 Jul 2008 11:45:28 -0700
Message-ID: <m1r69stkmv.fsf__19059.7233748578$1216321020$gmane$org@frodo.ebiederm.org>
References: <487F5D6B.1090007@hozac.com> <487F5EDB.1000008@openvz.org>
	<43011.192.168.102.6.1216308280.squirrel@intranet>
	<m13am8wgk6.fsf@frodo.ebiederm.org>
	<33935.192.168.102.6.1216319954.squirrel@intranet>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <33935.192.168.102.6.1216319954.squirrel@intranet> (Daniel Hokka
	Zakrisson's message of "Thu, 17 Jul 2008 20:39:14 +0200 (CEST)")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Hokka Zakrisson <daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

"Daniel Hokka Zakrisson" <daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org> writes:

> Looks like you've already done that. :-) (Referring to Sukadev's email.)
> Is there any reason we don't just merge that patch?

I knew I had done something like that.  Sure let's revive the patch and send
it.   I don't know why it got lost the first time.

Eric

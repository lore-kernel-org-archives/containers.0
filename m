From: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
Subject: Re: [Devel] Re: [RFC PATCH 0/5] Resend - Use procfs to change
	a	syscall behavior
Date: Thu, 10 Jul 2008 11:14:18 +0200
Message-ID: <4875D2EA.4010407@bull.net>
References: <20080703144013.737951000@bull.net>	<20080704102702.GB4531@elf.ucw.cz>
	<486E1276.2080605@bull.net>	<20080708105143.GA15311@elf.ucw.cz>
	<20080708214721.GA1972@us.ibm.com>	<20080708215315.GD17083@elf.ucw.cz>
	<4875B212.5030604@bull.net>
	<6599ad830807100001j3f3a6cf2y7a19dda9382edb2c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830807100001j3f3a6cf2y7a19dda9382edb2c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Wed, Jul 9, 2008 at 11:54 PM, Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org> wrote:
> 
>>Don't you think it's simpler to specify the target fd, and then open the
>>file.
> 
> 
> Maybe. But:
> 
> - this can already be done without extra kernel support, via open()
> followed by dup2()

Sure, I completely agree with you.
Actually, that's the way it is handled in cryo code.
But I think that both ways of doing are not exactly the same in case of 
failure:
open + dup2 will close newfd if it is already busy.
while
next-syscall_data + open will fail if the target fd is already busy. And 
that's the functionality we need during restart, isn't it?

Regards,
Nadia

> 
> - if you were going to add it to the kernel, the precedent set by
> openat() is that you create a new system call that supports the
> extended semantics.
> 
> 

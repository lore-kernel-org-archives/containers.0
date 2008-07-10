From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] Re: [RFC PATCH 0/5] Resend - Use procfs to change a
	syscall behavior
Date: Thu, 10 Jul 2008 00:01:55 -0700
Message-ID: <6599ad830807100001j3f3a6cf2y7a19dda9382edb2c@mail.gmail.com>
References: <20080703144013.737951000@bull.net>
	<20080704102702.GB4531@elf.ucw.cz> <486E1276.2080605@bull.net>
	<20080708105143.GA15311@elf.ucw.cz> <20080708214721.GA1972@us.ibm.com>
	<20080708215315.GD17083@elf.ucw.cz> <4875B212.5030604@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4875B212.5030604-6ktuUTfB/bM@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Jul 9, 2008 at 11:54 PM, Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org> wrote:
>
> Don't you think it's simpler to specify the target fd, and then open the
> file.

Maybe. But:

- this can already be done without extra kernel support, via open()
followed by dup2()

- if you were going to add it to the kernel, the precedent set by
openat() is that you create a new system call that supports the
extended semantics.


Paul

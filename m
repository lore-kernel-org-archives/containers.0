From: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
Subject: Re: [Devel] Re: [RFC PATCH 0/5] Resend - Use procfs to change
	a	syscall behavior
Date: Thu, 10 Jul 2008 11:38:45 +0200
Message-ID: <4875D8A5.2040201@bull.net>
References: <20080703144013.737951000@bull.net>	<20080704102702.GB4531@elf.ucw.cz>
	<20080707190119.GB25934@us.ibm.com>	<20080708105228.GB15311@elf.ucw.cz>
	<20080708215034.GB2179@us.ibm.com>	<20080708215821.GE17083@elf.ucw.cz>	<20080709022035.GA21249@us.ibm.com>
	<4875C138.5060506@bull.net>
	<6599ad830807100134l362ab98bt868e078eeb17b838@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830807100134l362ab98bt868e078eeb17b838-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
> On Thu, Jul 10, 2008 at 12:58 AM, Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org> wrote:
> 
>>Actually, what I've started working on these days is replace the proc
>>interface by a syscall to set the next_syscall_data field: I think this
>>might help us avoid defining a precise list of the new syscalls we need?
> 
> 
> Isn't that just sys_indirect(), but split into two syscall invocations
> rather than one?
> 

Yes, from what I've read about the sys_indirect(), it is.
Unfortunalty, I hadn't followed the thread, so except because of its 
"ugliness" (again ;-) ) I don't exactly know why the idea has been given up.

Regards,
Nadia

From: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
Subject: Re: [Devel] Re: [RFC PATCH 0/5] Resend - Use procfs to change a
	syscall behavior
Date: Thu, 10 Jul 2008 12:11:20 +0200
Message-ID: <4875E048.806@bull.net>
References: <20080703144013.737951000@bull.net>	
	<20080704102702.GB4531@elf.ucw.cz> <486E1276.2080605@bull.net>	
	<20080708105143.GA15311@elf.ucw.cz>
	<20080708214721.GA1972@us.ibm.com>	
	<20080708215315.GD17083@elf.ucw.cz> <4875B212.5030604@bull.net>	
	<6599ad830807100001j3f3a6cf2y7a19dda9382edb2c@mail.gmail.com>	
	<4875D2EA.4010407@bull.net>
	<6599ad830807100230k2f3f3551sa4b804f4c20b43fe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830807100230k2f3f3551sa4b804f4c20b43fe-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
> On Thu, Jul 10, 2008 at 2:14 AM, Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org> wrote:
> 
>>But I think that both ways of doing are not exactly the same in case of
>>failure:
>>open + dup2 will close newfd if it is already busy.
>>while
>>next-syscall_data + open will fail if the target fd is already busy. And
>>that's the functionality we need during restart, isn't it?
> 
> 
> No, I don't think so. The cryo restart code should be aware of exactly
> which fds it has open and which it needs to open, and can shuffle them
> around as necessary via dup2() to get them into the right places.
> 

Yes sure, that's exactly what it does.

what I just wanted to say here is that the concept of opening + dup2'ing 
is not exactly the same as the open_with_id concept.

But I agree with you: a restart code knows exactly what it does and can 
safely play with the open and dup syscalls.

Regards,
Nadia

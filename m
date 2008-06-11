From: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Subject: Re: [PATCH 0/2] cryo: Re-enable checkpointing of thread area
Date: Wed, 11 Jun 2008 16:41:44 +0200
Message-ID: <484FE428.3020203@bull.net>
References: <20080611141350.541711754@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080611141350.541711754-4vkkeT0zb4ZEtYaxpPmRp1aPQRlvutdw@public.gmane.org>
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
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Benjamin Thery wrote:
> I found the cause of one of the general protection faults I saw with
> my test program and I finally managed to completely restart (a very 
> dumb) program for the first time!
> 
> My program was failing (GPF) at restart in glibc code. After some 
> debugging I found the failures occur on SINGLE_THREAD_P calls 
> (eg. glibc/sysdeps/posix/system.c:__libc_system()).
> 
> I suspected a problem with nptl and remembered the comments in cr.c 
> ("for redhat 9.0, NPTL") and in cr.txt ("Support linuxthreads, but not 
> NPTL."). I uncommented this code that checkpoints the thread area 
> (don't ask me what it is) and, voila, my program restarted!
> 
> It doesn't solve everything: I still have issues restarting the 'sleep'
> program.

I spoke too fast... in fact I have no more issue with sleep or mksysvipc 
programs. They both restart fine now. :)

Benjamin


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com

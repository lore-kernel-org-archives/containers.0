From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: 2.6.33-rc4 i686 clone function looping (seems real!)
Date: Tue, 19 Jan 2010 16:15:35 -0600
Message-ID: <20100119221535.GA13141@us.ibm.com>
References: <1263852243.4745.363.camel@Mercier.safe.ca>
	<20100119150931.GA7708@us.ibm.com>
	<1263916851.4745.386.camel@Mercier.safe.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1263916851.4745.386.camel-4BUXZ/Ty1v7iqR6jatDSCA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jean-Marc Pigeon <jmp-4qkeo2rQ0gg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Jean-Marc Pigeon (jmp-4qkeo2rQ0gg@public.gmane.org):
> Hello Serge,
> 
> 	Thanks for the small test, I do confirm
> 	there is the same problem here with it, 
> 	as soon started the program use ALL available 
> 	CPU cycle (minus some few %) and NEVER
> 	EVER come back from "clone" function.
> 	The ONLY way I found to recover the
> 	system is to power it down (sic!).
> 
> 	See attachment, your program, the 
> 	.config file, and cpu information
> 	(I put back your test too, (done 
> 	 cosmetic changes only)).
> 
> 	Once again, clone call on 2.6.32.3
> 	is working fine.
> 
> 	Sorry to bother the list, I was "expecting"
> 	a Stack size problem, but I increase
> 	your value from 4 to 10, with the same result.
> 	Hopefully it could be something I overlooked
> 	with my Kernel config file, if someone
> 	want to have a look I attached it.
> 
> 	My guess for now it is something within
> 	the clone code specific to i386.
> 	
> 	I 'll try to pin point within the 
> 	clone code.
> 
> 	(could someone check tstclone.c under 
> 	 i386 arch and confirm trouble?)

Also might echo 1 > /proc/sys/kernel/sysrq before running the test, then
hit alt-sysrq-d to show all locks being held, alt-sysrq-l to show
stacks, alt-sysrq-p to dump registers, and alt-sysrq-t to dump tasks.

-serge

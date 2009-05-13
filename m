From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Segmentation fault @ checkpoint
Date: Wed, 13 May 2009 16:37:03 -0500
Message-ID: <20090513213703.GA23429@us.ibm.com>
References: <5B2F91AA-3148-4E5A-A464-773BE9B1E5CE@uni-duesseldorf.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5B2F91AA-3148-4E5A-A464-773BE9B1E5CE-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ralph-Gordon Paul <Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Ralph-Gordon Paul (Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org):
> Hi,
> 
> i'm trying out the checkpointer (version 15 from http://git.ncl.cs.columbia.edu/?p=linux-cr.git;a=shortlog;h=refs/heads/ckpt-v15) 
> .
> 
> i used the the example programs at the checkpointer documentation:  
> test.c and ckpt.c (i had to add #define __NR_checkpoint 333)
> 
> after compilation i tried:
> ./test &
> kill -STOP 3058                3058 = PID from test
> ./ckpt 3058 > ckpt.image
> 
> now i get a Segmentation fault (it's at the syscall(__NR_checkpoint.  
> pid, STDOUT_FILENO, 0) line).

Hi Gordon,

Just to make sure, did you check out the v15-dev branch of user-cr?
By default you get the v14 branch which is not compatible.  I
suspect you're using v14 becaues sys_checkpoint is being
called with flags 0, not 4, which is (now) wrong.

thanks,
-serge

> dmesg:
> [ 3948.213442] ckpt[3218]: segfault at 46 ip b7e1213d sp bf835e18  
> error 4 in libc-2.7.so[b7db4000+155000]
> 
> Any idea what may be the problem?
> Do i have a problem with my libc?
> 
> My System spec:
> Debian 5.0 i686
> CPU: AMD Athlon XP 2000+
> 
> Regards,
> Gordon
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

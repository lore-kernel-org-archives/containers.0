From: Veerendra Chandrappa <vechandr-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
Subject: Re: [LTP] [PATCH 0/4] Helper patches for PTY namespaces
Date: Mon, 14 Apr 2008 18:01:11 +0530
Message-ID: <OF766ECBB8.8B7DAFCE-ON6525742B.00437346-6525742B.0043FD8A@in.ibm.com>
References: <20080412172933.GA19295@us.ibm.com>	
	<bb33bcf20804121039u409ae37q2dead849ca24dfa@mail.gmail.com>
	<20080412180533.GE19449@us.ibm.com>
	<1208172006.5762.21.camel@subratamodak.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1208172006.5762.21.camel-NRFfyExJdYpgXGGE5LP+UZlqa2bBAFbm0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: ltp-list <ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Rishikesh K Rajak <risrajak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Subrata Modak <tosubrata-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Sukadev,

      That sounds nice, I will integrate them with the LTP.
Of course it depends on the order of priority, and as I am learning the
tricks of container/ltp .

Regards, Veerendra C
________________________________________________________
Linux Technology Center, India Software Labs, Bangalore, Ph: 080-4177 6428


                                                                           
             Subrata Modak                                                 
             <subrata-23VcF4HTsmI@public.gmane.org                                             
             et.ibm.com>                                                To 
                                       sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Veerendra       
             04/14/2008 04:50          Chandrappa/India/IBM@IBMIN          
             PM                                                         cc 
                                       Subrata Modak                       
                                       <tosubrata-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew       
             Please respond to         Morton <akpm-3NddpPZAyC0@public.gmane.org>, ltp-list    
             subrata-23VcF4HTsmKzQB+pC5nmwQ@public.gmane.org         <ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,   
                 t.ibm.com             "Eric W. Biederman"                 
                                       <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Rishikesh  
                                       K Rajak/India/IBM@IBMIN,            
                                       matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, 
                                       Containers                          
                                       <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel  
                                       Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>        
                                                                   Subject 
                                       Re: [LTP] [PATCH 0/4] Helper        
                                       patches for PTY namespaces          
                                                                           
                                                                           
                                                                           
                                                                           
                                                                           
                                                                           




On Sat, 2008-04-12 at 11:05 -0700, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> Subrata Modak [tosubrata-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org] wrote:
> | Sukadev,
> |
> | Any corresponding test cases for LTP. We just have UTS, PID & SYSVIPC
> | Namespace till now.
>
> I had some unit-tests that I used with the clone-pts-ns patchset.
> But the patches in this set are just helpers and should not change
> existing functionality.
>
> I can send the tests I used (they are not in LTP format) when I tested
> the clone-pts-ns patchset.

Looping in Veerandra. He may be able to help us here.

Regards--
Subrata

>
> Thanks,
>
> Sukadev
>
> -------------------------------------------------------------------------
> This SF.net email is sponsored by the 2008 JavaOne(SM) Conference
> Don't miss this year's exciting event. There's still time to save $100.
> Use priority code J8TL2D2.
>
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone

> _______________________________________________
> Ltp-list mailing list
> Ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
> https://lists.sourceforge.net/lists/listinfo/ltp-list

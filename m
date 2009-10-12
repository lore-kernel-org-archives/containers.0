From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: pidns memory leak
Date: Mon, 12 Oct 2009 10:41:43 +0200
Message-ID: <4AD2EBC7.2020109@fr.ibm.com>
References: <4AC5F198.2070407@fr.ibm.com>
	<20091006040526.GA22923@us.ibm.com>	<4ACAFD6A.3060008@fr.ibm.com>	<20091008030828.GA18973@us.ibm.com>
	<4ACD9ECC.90508@fr.ibm.com>	<20091009032928.GA2031@us.ibm.com>
	<4ACF381F.9050808@fr.ibm.com> <20091010013235.GA11904@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091010013235.GA11904-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, andrea-Vyt77T80VFVWk0Htik3J/w@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu wrote:
> Ccing  Andrea's new email id:
>
> Daniel Lezcano [dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org] wrote:
>   
>> Following your explanation I was able to reproduce a simple program  
>> added in attachment. But there is something I do not understand is why  
>> the leak does not appear if I do the 'lstat' (cf. test program) in the  
>> pid 2 context.
>>     
>
> Hmm, are you sure there is no leak with this test program ? If I put back
> the commit (7766755a2f249e7), I do see a leak in all three data structures
> (pid_2, proc_inode, pid_namespace).
>   

Let me clarify :)

The program leaks with the commit 7766755a2f249e7 and does not leak 
without this commit.
This is the expected behaviour and this simple program spots the problem.

I tried to modify the program and I moved the lstat to the process 2 in 
the child namespace. Conforming your analysis, I was expecting to see a 
leak too, but this one didn't occur. I was wondering why, maybe there is 
something I didn't understood in the analysis.

Thanks
  -- Daniel

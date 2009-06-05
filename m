From: Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] CPU hard limits
Date: Fri, 05 Jun 2009 15:57:54 +0300
Message-ID: <4A291652.4090308__9935.94747637889$1244206817$gmane$org@redhat.com>
References: <4A27BBCA.5020606@redhat.com> <20090605030309.GA3872@in.ibm.com>
	<4A28921C.6010802@redhat.com>
	<661de9470906042137u603e2997n80c270bf7f6191ad@mail.gmail.com>
	<4A28A2AB.3060108@redhat.com>
	<20090605044946.GA11755@balbir.in.ibm.com>
	<20090605051050.GB11755@balbir.in.ibm.com>
	<4A28AB67.7040800@redhat.com>
	<20090605052755.GE11755@balbir.in.ibm.com>
	<4A28B539.3050001@redhat.com> <20090605063243.GC3872@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090605063243.GC3872-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: bharata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Gautham R Shenoy <ego-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Bharata B Rao wrote:
>> So the groups with guarantees get a priority boost.  That's not a good  
>> side effect.
>>     
>
> That happens only in the presence of idle cycles when other groups [with or
> without guarantees] have nothing useful to do. So how would that matter
> since there is nothing else to run anyway ?
>   

If there are three groups, each running a cpu hog, and they have (say) 
guarantees of 10%, 10%, and 0%, then they should each get 33% of the 
cpu, not biased towards the groups with the guarantee.

If I want to change the weights, I'll alter their priority.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

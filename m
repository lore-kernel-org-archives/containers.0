From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 1/9] exec_path 1/9: introduce ->exec_path and switch
	/proc/*/exe
Date: Fri, 5 Jun 2009 09:48:02 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0906050942450.6847@localhost.localdomain>
References: <20090526113618.GJ28083@us.ibm.com>
	<20090526162415.fb9cefef.akpm@linux-foundation.org>
	<20090531215427.GA29534@x200.localdomain>
	<20090531151953.8f8b14b5.akpm@linux-foundation.org>
	<20090603230422.GB853@x200.localdomain>
	<20090605104517.GA11713@infradead.org>
	<alpine.LFD.2.01.0906050808551.6847@localhost.localdomain>
	<20090605154147.GA16766@x200.localdomain>
	<alpine.LFD.2.01.0906050848520.6847@localhost.localdomain>
	<20090605160943.GA5262@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090605160943.GA5262-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org



On Fri, 5 Jun 2009, Alexey Dobriyan wrote:
> 
> It's borrowed by kernel thread of course, not userspace task.

.. and even if it is, what's the problem? 

That kernel thread has borroed whe VM for a while. It effectively _is_ a 
thread of the process now. So it's technically not even wrong to 
explicitly allow things like /proc/*/exe to see it as such.

But you can hide it by just checking some flag in the thread structure if 
you really want to.

But when creating a regular thread, you should _not_ need to take a 
spinlock and duplicate the executable path!

		Linus

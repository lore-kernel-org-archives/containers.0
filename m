From: Kirill Korotaev <dev-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [Devel] [PATCH] Allow signalling container-init
Date: Thu, 09 Aug 2007 12:16:07 +0400
Message-ID: <46BACD47.8030703@sw.ru>
References: <20070808234737.GA18334@us.ibm.com> <87vebph6vq.fsf@rimspace.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87vebph6vq.fsf-zvVxMF7wGoXk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Pittman <daniel-zvVxMF7wGoXk1uMJSBkQmQ@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org

Daniel Pittman wrote:
> sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org writes:
> 
> 
>>Should we include this in the patchset ?
> 
> 
> [...]
> 
> 
>>Only the global-init process must be special - any other
>>container-init process must be killable to prevent run-away processes
>>in the system.
> 
> 
> One problem I hit while using OpenVZ is that some init processes --
> notable upstart used by Ubuntu -- depend on the special signal processing
> extended to init by the kernel.
> 
> The problem here was that a signal the kernel would otherwise have
> blocked was sent to upstart, the default handler was invoked and init
> was terminated.
> 
> 
>>TODO:	Ideally we should allow killing the container-init only from
>>	ancestor containers and prevent it being killed from that or
>>	descendant containers.  But that is a more complex change and
>>	will be addressed by a follow-on patch. For now allow the
>>	container-init to be terminated by any process with sufficient
>>	privileges.
> 
> 
> This will break, as far as I can see, by allowing the container root to
> send signals to init that it doesn't expect.

This was fixed in OpenVZ in recent kernels and Pavel tried to address this in
pid namespace patches as well, but since no beatiful solution was found
it was decided to postpone this issue.

NOTE: parent can still send signals to child container' init. This
   is convinient since you can terminate the whole container quickly from
   the host node.

Thanks,
Kirill

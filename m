From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: kernel based checkpoint/restart: about X windows application
	checkpoint and restart support.
Date: Wed, 28 Oct 2009 12:18:17 -0400
Message-ID: <4AE86EC9.7040605@librato.com>
References: <20091028084717.GO31446@count0.beaverton.ibm.com>
	<4AE85D13.9030108@librato.com>
	<20091028161219.GQ31446@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091028161219.GQ31446-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Will Huang <will.huang-lvxLlxTUKJQIhP1ydL5T/A@public.gmane.org>
List-Id: containers.vger.kernel.org



Matt Helsley wrote:
> On Wed, Oct 28, 2009 at 11:02:43AM -0400, Oren Laadan wrote:
>>
>> Matt Helsley wrote:
>>> On Wed, Oct 28, 2009 at 10:51:32AM +0800, Will Huang wrote:
>>>> Dear All,
>>>>
>>>>          Did the Kernel based checkpoint/restart patch support X windows
>>>> application such as firefox?
>>> No, and I think it may be a long time before that happens.
>> In short: not yet, but we're getting closer.
>>
> 
> <snip> (lots of good background)
>  
>> Now back to your question: X applications cannot be checkpointed
>> standalone (unless, of course, X windows is modified for that).
>> Instead, one must checkpoint the entire user session, including
>> the X server itself.
>>
>> The main problem is that the X server is "talking" to the bare
>> hardware, and the task of recording the specific hardware state
>> and restoring it later is daunting, and becomes impossible if the
>> session is to be restarted on different hardware.
>>
>> The solution is to not run the regular X server. Instead, start
>> a virtual X server, such as VNC, and run the user session in it.
>> The main difference is that VNC server does not directly use any
>> hardware resources, so it is not tied to specific hardware state.
>> From the user's point of view - this setup is transparent with
>> suitable use of a VNC client.
> 
> VNC is all well and good but it's hardly the norm for local
> desktops to run under an X server with a VNC display. That said,
> VNC support is much closer than any of my hare-brained ideas so..

There is a lot of work on server/client split of the X server
(of which VNC is one), and also work on embedding one display
manager within another (e.g. nested X, and also similar ideas
done with embedding a VM window in the desktop as a regular
window etc).

So eventually, I believe, embedding a (virtualized) X server in
an outside X server and running the entire desktop in a container
will eventually be possible in a manner transparent to the user.

And this is much more likely than checkpoint the standard X
server including all it's hardware related state...

Changing the norm starts now :)

Oren.

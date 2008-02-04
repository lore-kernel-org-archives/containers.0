From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [PATCH 2.6.24-rc8-mm1 00/15] IPC: code rewrite + new
	functionalities
Date: Mon, 4 Feb 2008 20:51:50 +0100
Message-ID: <20080204195150.GA4915__6524.85230607471$1202155157$gmane$org@elf.ucw.cz>
References: <20080129160229.612172683@bull.net> <20080202182351.GC4456@ucw.cz>
	<47A732E2.1000504@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <47A732E2.1000504-6ktuUTfB/bM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi!

>>> 	As the namespaces and the "containers" are being integrated in the
>>> kernel, these functionalities may be a first step to implement  the
>>> checkpoint/restart of an application: in fact the existing API does not allow
>>> to specify or to change an ID when creating an IPC, when restarting an
>>> application, and the times/pids values of each IPCs are also altered. May be
>>> someone may find another interest about this ?
>>>
>>> So again, comments are welcome.
>>
>> Checkpoint/restart is nice, but... sysV ipc is broken by design, do we
>> really want to extend it?

>
> For my personal culture, what do you mean by "broken by design"?


       int shmget(key_t key, size_t size, int shmflg);

....so how do you produce key in a way that is guaranteed not to
interfere with other uses?
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

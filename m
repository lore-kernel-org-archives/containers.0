From: Gandalf Corvotempesta <gandalf.corvotempesta-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Escape from a bind mount
Date: Thu, 22 Sep 2016 15:57:26 +0200
Message-ID: <CAJH6TXjU1cFRa_-mnE1Yv5g3uH+3sNPUMafuzMRXMTR2VKfehA@mail.gmail.com>
References: <CAJH6TXhzy4XAQKaKjrK5Yqzg0sxtPjU9D=X3AHZZ76N3Cpwkwg@mail.gmail.com>
	<20160922130253.GB20504@pc.thejh.net>
	<CAJH6TXje-Zb54scg8-UTchZEa2RCOGVdaB0DQ_ipbJtNEAPPGA@mail.gmail.com>
	<20160922134833.GC20504@pc.thejh.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160922134833.GC20504-J1fxOzX/cBvk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

2016-09-22 15:48 GMT+02:00 Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>:
> It shouldn't be possible to escape from bind mounts anymore. That was a
> bug, and it was fixed.
> Where do the docs mention this? We should probably ask them to fix that.

Here:
https://docs.docker.com/engine/tutorials/dockervolumes/

But I've opened an issue to let them fix.

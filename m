From: Gandalf Corvotempesta <gandalf.corvotempesta-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Escape from a bind mount
Date: Thu, 22 Sep 2016 15:31:45 +0200
Message-ID: <CAJH6TXje-Zb54scg8-UTchZEa2RCOGVdaB0DQ_ipbJtNEAPPGA@mail.gmail.com>
References: <CAJH6TXhzy4XAQKaKjrK5Yqzg0sxtPjU9D=X3AHZZ76N3Cpwkwg@mail.gmail.com>
	<20160922130253.GB20504@pc.thejh.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160922130253.GB20504-J1fxOzX/cBvk1uMJSBkQmQ@public.gmane.org>
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

2016-09-22 15:02 GMT+02:00 Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>:
> This was fixed by Eric Biederman in the "Bind mount escape fixes" patch series
> in August 2015.
> Relevant commits are 397d425d and cde93be4 (maybe more? I'm not sure).

So, now is not possible to escape from bind ? There was a reference to
this in official Docker docs.

Just for my info: to escape from the container, an attacker would have
to move the bound directory directly from the host? Having access only
to the container would't make this issue happen ?
In example, if I have bound as follow:
   /mnt/dir1 => /home/myuser/path_inside_container

moving (from the host) /mnt/dir1 to somewhere else like /tmp/dir1 will
make the container able to escape ?

From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH] new cgroup controller "fork"
Date: Thu, 3 Nov 2011 15:50:09 -0200
Message-ID: <4EB2D451.4010607@parallels.com>
References: <20111103162238.27609.11515.stgit@rabbit.intern.cm-ag>
	<20111103164302.GE8198@somewhere.redhat.com>
	<20111103171645.GA27887@rabbit.intern.cm-ag>
	<4EB2CEB2.7050800@parallels.com>
	<20111103174809.GA28108@rabbit.intern.cm-ag>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111103174809.GA28108-Rjmu19FXx3rR8JxBgnUBv+rzNCUFrscg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>
Cc: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 11/03/2011 03:48 PM, Max Kellermann wrote:
> On 2011/11/03 18:26, Glauber Costa<glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>  wrote:
>> On 11/03/2011 03:16 PM, Max Kellermann wrote:
>>> but is different from my controller.
>>>
>> How so?
>
> Once the "remaining" counter has reached zero, no further forks are
> possible, no matter how many processes are left.  It is a fork
> counter, not a process counter.
>
> Let's say: Frederic's controller counts "things" that exists
> (processes), and my controller counts "verbs" or "ations" (fork()).
>
> Max
That still seems to be up to admin. If no processes are removed from the 
cgroup or included in the cgroup, the only action/verb the counter
is concerned about is to fork. Under this circumstance, both seem 
equivalent from my PoV.

From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH] new cgroup controller "fork"
Date: Thu, 3 Nov 2011 15:26:10 -0200
Message-ID: <4EB2CEB2.7050800@parallels.com>
References: <20111103162238.27609.11515.stgit@rabbit.intern.cm-ag>
	<20111103164302.GE8198@somewhere.redhat.com>
	<20111103171645.GA27887@rabbit.intern.cm-ag>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111103171645.GA27887-Rjmu19FXx3rR8JxBgnUBv+rzNCUFrscg@public.gmane.org>
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

On 11/03/2011 03:16 PM, Max Kellermann wrote:
> On 2011/11/03 17:43, Frederic Weisbecker<fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>  wrote:
>> Please have a look at the task counter subsystem: https://lwn.net/Articles/461462/
>>
>> It's in the -mm tree. I'm glad to hear about another user who wants
>> this feature in cgroups. We need to hear about you and whether this
>> meets your requirements in order to get it merged upstream.
>
> Had a quick look at your patch set.  No, it does not seem to meet my
> requirements.  It limits the number of processes in a cgroup - that is
> also very useful, but is different from my controller.
>
How so?
If you never move tasks to a cgroup except at setup time - which is the 
common case for almost everybody, I imagine, you end up achieving the 
same thing.

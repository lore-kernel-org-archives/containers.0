From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [GIT PULL] cgroup changes for v3.15-rc1
Date: Fri, 4 Apr 2014 18:34:05 -0700
Message-ID: <CA+55aFwM0aG1PHY7xOQbsFG+Ot4mL4=7yRnT7dssUaOyaLQ3GQ@mail.gmail.com>
References: <20140403164911.GE24119@htj.dyndns.org>
	<CA+55aFyGz2q4iDEt56Bw+x_ri_-DQYLAKPJvk3Uxj9z-y+0uPw@mail.gmail.com>
	<CA+55aFy+Jt0B32kj=Ldz9Krp4DXcXSP4r-o3f-2LPcVs4udGVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CA+55aFy+Jt0B32kj=Ldz9Krp4DXcXSP4r-o3f-2LPcVs4udGVA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Apr 4, 2014 at 6:11 PM, Linus Torvalds
<torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
>
> I'll try to pick kernels away from that, but that makes bisection much
> less effective.

Ok, I think I'm away from the broken region. The problem seems to be in between

good: 8e30e2b8ba0e ("cgroup: restructure locking and error handling in
cgroup_mount()")

bad: 6f30558f37bf ("cgroup: make cgroup hold onto its kernfs_node")

and let's see what bisect says about the rest.. Does that give you any ideas?

            Linus

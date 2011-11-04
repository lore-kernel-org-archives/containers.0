From: Max Kellermann <max-hDT0AjmEH7RAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH] new cgroup controller "fork"
Date: Fri, 4 Nov 2011 14:38:48 +0100
Message-ID: <20111104133848.GA9116__33029.7379209243$1320416043$gmane$org@Debian-60-squeeze-64-minimal>
References: <20111103165903.GA4755@Debian-60-squeeze-64-minimal>
	<20111103182101.5037c1e5@lxorguk.ukuu.org.uk>
	<20111103185108.GA5153@Debian-60-squeeze-64-minimal>
	<20111103190330.02590426@lxorguk.ukuu.org.uk>
	<20111103192039.GA5300@Debian-60-squeeze-64-minimal>
	<4EB2EA93.2050206@parallels.com> <4EB2F5CF.5010604@aljex.com>
	<4EB30DAF.4090704@parallels.com> <4EB3560D.7000002@cn.fujitsu.com>
	<4EB3E47E.2080003@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4EB3E47E.2080003-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2011/11/04 14:11, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:
> For other uses, we can watch the task counter increase until a
> certain value, and then set the limit to 0.
> 
> Max, wouldn't it be enough for your use?

No.  We do have a process limit already (I didn't publish it yet), but
we might adopt Frederic's new controller as soon as it hits our
servers.  The fork controller complements it, and we have many others.
We run a shared CGI hosting platform with millions of accounts, and
many users have badly designed or even vulnerable PHP scripts.  The
fork controller is very effective at stopping certain kinds of those.
Other controllers shall keep other problems small.  This mix of many
different measures has been working very well for quite a few years.

We'll just keep that code on our private git repository .. rebasing on
new kernel releases is easy enough for me.

Max

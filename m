From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2] core_pattern: set core helpers root and namespace to
	crashing process
Date: Fri, 14 Dec 2012 15:10:30 -0800
Message-ID: <87d2ycut5l.fsf@xmission.com>
References: <1355255996-25953-1-git-send-email-nhorman@tuxdriver.com>
	<1355519048-28473-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1355519048-28473-1-git-send-email-nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> (Neil
	Horman's message of "Fri, 14 Dec 2012 16:04:08 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> writes:

> As its currently implemented, redirection of core dumps to a pipe reader should
> be executed such that the reader runs in the namespace of the crashing process,
> and it currently does not. This is the only sane way to deal with namespaces
> properly it seems to me, and this patch implements that functionality.

I actually rather strongly disagree.

While we have a global core dump pattern core dumps to a a pipe reader
should be executed such that the reader runs in the namespace of the
process that set the pattern.  We can easily restrict that to the
initial namespaces to make the implementation simpler.

If you want to play namespace games you can implement all of those in
user space once my tree merges for v3.8.

I am really not a fan of the trigger process being able to control the
environment of a privileged process.  It makes writing the privileged
process much trickier.

Eric

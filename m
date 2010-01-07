From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 1/2] Add clone_child control file
Date: Wed, 6 Jan 2010 17:28:58 -0800
Message-ID: <6599ad831001061728n63375ff8qb3a084e3f9fd7c98@mail.gmail.com>
References: <20091228230454.000895089@mai.lab.toulouse-stg.fr.ibm.com>
	<20091228230620.494084022@mai.lab.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091228230620.494084022-7Ha4D/yM3XKqUVqbrEjtMkN0fxke0PB7qyM6JfAXOaQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Dec 28, 2009 at 3:04 PM, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:
> This patch is sent as an answer to a previous thread around the ns_cgroup.
>
> https://lists.linux-foundation.org/pipermail/containers/2009-June/018627.html
>
> It adds a control file 'clone_children' for a cgroup.
> This control file is a boolean specifying if the child cgroup should
> be a clone of the parent cgroup or not. The default value is 'false'.
>
> This flag makes the child cgroup to call the post_clone callback of all
> the subsystem, if it is available.

Basic idea looks OK, and it seems like a plausible way to handle
automatic construction/inheritance of control values. I have a minor
worry that it might not be fine-grained enough though - are there
maybe cases where you'd want cloning for one subsystem but not for
others? I suppose in that case you can just put them on separate
hierarchies.

The file should be called cgroup.clone_children rather than plain
clone_children, to fit in with the other new generic-cgroup control
files that we've started introducing, and to avoid naming clashes.

Paul

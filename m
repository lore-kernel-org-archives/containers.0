From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: Loadable cgroup subsystems
Date: Mon, 7 Apr 2008 22:43:43 -0700
Message-ID: <6599ad830804072243i35e5b134q1d04f2bd121f8f69@mail.gmail.com>
References: <1207633175.7798.5.camel@nikanth-laptop.blr.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1207633175.7798.5.camel-6V/ZMFSzLJEY2a5ovjdQkMfQ/htzPhTPEvhb3Hwu1Ks@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Apr 7, 2008 at 10:39 PM, Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org> wrote:
>
>  Why not provide a interface to add subsystems at run-time instead?
>  Are there any reason for not letting a subsystem to be implemented as a
>  loadable module? IOW make cgroups usable by modules?
>

Having all the subsystems declared at compile time makes a lot of
things (number of subsystems, size of css_set, etc) statically known,
which makes the code clearer and more importantly eliminates a bunch
of locking/synchronization overhead.

It would be possible to make cgroups support dynamically-loaded
subsystems, and in fact, some of the earliest cgroups patches did
support this, for a predefined max number of subsystems. But it would
introduce more complexity and overhead.

I'd rather not add support for this without a strong case of a
subsystem that really needs to be dynamically loaded.

Paul

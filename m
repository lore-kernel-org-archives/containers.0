From: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Subject: Loadable cgroup subsystems
Date: Tue, 08 Apr 2008 11:09:35 +0530
Message-ID: <1207633175.7798.5.camel@nikanth-laptop.blr.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

> On 4/1/08, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org> wrote:
>  > > > > --- a/include/linux/cgroup_subsys.h
>  > > > > +++ b/include/linux/cgroup_subsys.h
>  > > > > @@ -42,3 +42,9 @@ SUBSYS(mem_cgroup)
>  > > > > #endif
>  > > > >
>  > > > > /* */
>  > > > > +
>  > > > > +#ifdef CONFIG_CGROUP_DEVICE
>  > > > > +SUBSYS(devices)
>  > > > > +#endif
>  > > > > +
>  > > > > +/* */
>  > > >
>  > > > I don't know what this is, but it does not look like C...
>  > >
>  > > Huh?
>  >
>  > Empty comments as separators?
> 
>  They help when multiple people add such SUBSYS things and
>  do not have to fight rejects.
> 

Why not provide a interface to add subsystems at run-time instead?
Are there any reason for not letting a subsystem to be implemented as a
loadable module? IOW make cgroups usable by modules?

Thanks
Nikanth Karthikesan

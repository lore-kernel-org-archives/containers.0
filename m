From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: Unprivileged containers and co-ordinating user namespaces
Date: Sun, 01 May 2016 16:29:26 -0700
Message-ID: <1462145366.2337.18.camel__21179.0947513238$1462145392$gmane$org@HansenPartnership.com>
References: <1461880928.2307.48.camel@HansenPartnership.com>
	<20160428230045.GS22888@odin.tremily.us>
	<1461944328.2311.10.camel@HansenPartnership.com>
	<1461968310.16292.20.camel@HansenPartnership.com>
	<1462120674.1411.2.camel@Nokia-N900>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1462120674.1411.2.camel@Nokia-N900>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, util-linux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, 2016-05-01 at 12:37 -0400, Serge Hallyn wrote:
> > > It looks like the only addition it needs is the setgroups flag
> > > for
> > > newgidmap, which the security people will need, so I can patch
> > > that. 
> > 
> > How does this look for a patch?
> 
> Certainly deny is a terrible keyword for this, given the somewhat
> convoluted case it represents.  Maybe lockgroups or nosetgroup?

OK, nosegroups seems to be less scary.

>   And of course it'll need a clear explanation of what it does in the
> subgid manpage. But really i don't know that this can work the way
> you want it to.

Yes, docs and tests were to be added after everyone was happy with the
implementation.

>   Can you describe your use case?

basically not getting a CVE filed against this utility for allowing the
dropping of groups.  I don't have a use case for group membership
denying permissions.

> The intent of setgroups is to keep *unprivileged* writers of gid_map
> from dropping a gid which is blocking a file access from the user. 


You can't do that with the map write.  Even if you set no gid_map at
all, the attributes checks are done on the kernel side groups (i.e. the
ones you possess outside the namespace even if they have no interior
mapping).  The only way to drop groups is with the setgroups() system
call.

>  But newgidmap runs suid root (or cap_gid when you are through :), so
> the user can trivially assign just one authorized gid, not the whole
> range, and bypass the acls that way.

It does more than that: it also blocks the sys_setgroups() call in the
namespace, even for the namespace owner, which is the primary CVE
preventing use case.

> At the very least you would want to enforce the use of a whole range
> in the lockgroup case, but even there i question it's value.

I think, if you were going to enforce deny sys_setgroups() on a user
you otherwise trusted, you'd probably only allow them a single range. 
 But I suppose the flag should be or'd over all ranges.

James


> -Serge
> 
> 
> 
> > James
> > 
> > ---
> > 
> > diff --git a/lib/subordinateio.c b/lib/subordinateio.c
> > index 0d64a91..aa3c968 100644
> > --- a/lib/subordinateio.c
> > +++ b/lib/subordinateio.c
> > @@ -18,9 +18,10 @@ struct subordinate_range {
> >        const char *owner;
> >        unsigned long start;
> >        unsigned long count;
> > +    const char *flags;
> >    };
> >    
> > -#define NFIELDS 3
> > +#define NFIELDS 4
> >    
> >    /*
> >      * subordinate_dup: create a duplicate range
> > @@ -44,6 +45,16 @@ static /*@null@*/ /*@only@*/void
> > *subordinate_dup
> > (const void *ent)         free(range);
> >            return NULL;
> >        }
> > +    if (rangeent->flags) {
> > +        range->flags = strdup (rangeent->flags);
> > +        if (NULL == range->flags) {
> > +            free((void *)range->owner);
> > +            free(range);
> > +            return NULL;
> > +        }
> > +    } else {
> > +        range->flags = NULL;
> > +    }
> >        range->start = rangeent->start;
> >        range->count = rangeent->count;
> >    
> > @@ -111,13 +122,17 @@ static void *subordinate_parse (const char
> > *line)
> >         * There must be exactly NFIELDS colon separated fields or
> >         * the entry is invalid.   Also, fields must be non-blank.
> >         */
> > -    if (i != NFIELDS || *fields[0] == '\0' || *fields[1] == '\0'
> > ||
> > *fields[2] == '\0') +    if ((i != NFIELDS && i != NFIELDS -1) ||
> > *fields[0] == '\0' || *fields[1] == '\0' || *fields[2] == '\0')    
> >     return
> > NULL;     range.owner = fields[0];
> >        if (getulong (fields[1], &range.start) == 0)
> >            return NULL;
> >        if (getulong (fields[2], &range.count) == 0)
> >            return NULL;
> > +    if (i == NFIELDS)
> > +        range.flags = fields[3];
> > +    else
> > +        range.flags = NULL;
> >    
> >        return &range;
> >    }
> > @@ -134,10 +149,11 @@ static int subordinate_put (const void *ent,
> > FILE
> > * file) {
> >        const struct subordinate_range *range = ent;
> >    
> > -    return fprintf(file, "%s:%lu:%lu\n",
> > +    return fprintf(file, "%s:%lu:%lu:%s\n",
> >                             range->owner,
> >                             range->start,
> > -                         range->count) < 0 ? -1   : 0;
> > +                         range->count,
> > +                         range->flags ? range->flags : "") < 0 ? 
> > -1   : 0;
> >    }
> >    
> >    static struct commonio_ops subordinate_ops = {
> > @@ -295,7 +311,8 @@ static const struct subordinate_range
> > *find_range(struct commonio_db *db,   * Returns true if @owner is
> > authorized to use the range, false otherwise.   */
> >    static bool have_range(struct commonio_db *db,
> > -                     const char *owner, unsigned long start,
> > unsigned long count)
> > +                     const char *owner, unsigned long start,
> > unsigned long count,
> > +                     const char **flags)
> >    {
> >        const struct subordinate_range *range;
> >        unsigned long end;
> > @@ -309,8 +326,11 @@ static bool have_range(struct commonio_db *db,
> >            unsigned long last; 
> >    
> >            last = range->start + range->count - 1;
> > -        if (last >= (start + count - 1))
> > +        if (last >= (start + count - 1)) {
> > +            if (flags)
> > +                *flags = range->flags;
> >                return true;
> > +        }
> >    
> >            count = end - last;
> >            start = last + 1;
> > @@ -430,7 +450,7 @@ static int add_range(struct commonio_db *db,
> >        range.count = count;
> >    
> >        /* See if the range is already present */
> > -    if (have_range(db, owner, start, count))
> > +    if (have_range(db, owner, start, count, NULL))
> >            return 1;
> >    
> >        /* Otherwise append the range */
> > @@ -585,7 +605,7 @@ bool sub_uid_assigned(const char *owner)
> >    
> >    bool have_sub_uids(const char *owner, uid_t start, unsigned long
> > count)
> >    {
> > -    return have_range (&subordinate_uid_db, owner, start, count);
> > +    return have_range (&subordinate_uid_db, owner, start, count,
> > NULL);
> >    }
> >    
> >    int sub_uid_add (const char *owner, uid_t start, unsigned long
> > count)
> > @@ -659,9 +679,9 @@ int sub_gid_open (int mode)
> >        return commonio_open (&subordinate_gid_db, mode);
> >    }
> >    
> > -bool have_sub_gids(const char *owner, gid_t start, unsigned long
> > count)
> > +bool have_sub_gids(const char *owner, gid_t start, unsigned long
> > count,
> > const char **flags) {
> > -    return have_range(&subordinate_gid_db, owner, start, count);
> > +    return have_range(&subordinate_gid_db, owner, start, count,
> > flags);
> >    }
> >    
> >    bool sub_gid_assigned(const char *owner)
> > diff --git a/lib/subordinateio.h b/lib/subordinateio.h
> > index a21d72b..7e47659 100644
> > --- a/lib/subordinateio.h
> > +++ b/lib/subordinateio.h
> > @@ -25,7 +25,7 @@ extern int sub_uid_remove (const char *owner,
> > uid_t
> > start, unsigned long count); extern uid_t
> > sub_uid_find_free_range(uid_t
> > min, uid_t max, unsigned long count); 
> >    extern int sub_gid_close(void);
> > -extern bool have_sub_gids(const char *owner, gid_t start, unsigned
> > long
> > count); +extern bool have_sub_gids(const char *owner, gid_t start,
> > unsigned long count, const char **flags); extern bool
> > sub_gid_file_present (void); extern bool sub_gid_assigned(const
> > char
> > *owner); extern int sub_gid_lock (void);
> > diff --git a/libmisc/idmapping.c b/libmisc/idmapping.c
> > index 0dce634..7f7de88 100644
> > --- a/libmisc/idmapping.c
> > +++ b/libmisc/idmapping.c
> > @@ -106,7 +106,6 @@ void write_mapping(int proc_dir_fd, int ranges,
> > struct map_range *mappings,     struct map_range *mapping;
> >        size_t bufsize;
> >        char *buf, *pos;
> > -    int fd;
> >    
> >        bufsize = ranges * ((ULONG_DIGITS   + 1) * 3);
> >        pos = buf = xmalloc(bufsize);
> > @@ -128,13 +127,20 @@ void write_mapping(int proc_dir_fd, int
> > ranges,
> > struct map_range *mappings,     }
> >    
> >        /* Write the mapping to the maping file */
> > +    write_proc(proc_dir_fd, map_file, buf, pos - buf);
> > +}
> > +
> > +void write_proc(int proc_dir_fd, const char *map_file, void *buf,
> > int
> > len) +{
> > +    int fd;
> > +
> >        fd = openat(proc_dir_fd, map_file, O_WRONLY);
> >        if (fd < 0) {
> >            fprintf(stderr, _("%s: open of %s failed: %s\n"),
> >                Prog, map_file, strerror(errno));
> >            exit(EXIT_FAILURE);
> >        }
> > -    if (write(fd, buf, pos - buf) != (pos - buf)) {
> > +    if (write(fd, buf, len) != len) {
> >            fprintf(stderr, _("%s: write to %s failed: %s\n"),
> >                Prog, map_file, strerror(errno));
> >            exit(EXIT_FAILURE);
> > diff --git a/libmisc/idmapping.h b/libmisc/idmapping.h
> > index 58d000f..c2cec38 100644
> > --- a/libmisc/idmapping.h
> > +++ b/libmisc/idmapping.h
> > @@ -39,6 +39,7 @@ struct map_range {
> >    extern struct map_range *get_map_ranges(int ranges, int argc,
> > char
> > **argv); extern void write_mapping(int proc_dir_fd, int ranges,
> >        struct map_range *mappings, const char *map_file);
> > +extern void write_proc(int proc_dir_fd, const char *map_file, void
> > *buf, int len); 
> >    #endif /* _ID_MAPPING_H_ */
> >    
> > diff --git a/src/newgidmap.c b/src/newgidmap.c
> > index 451c6a6..8d64e3b 100644
> > --- a/src/newgidmap.c
> > +++ b/src/newgidmap.c
> > @@ -46,14 +46,14 @@
> >      */
> >    const char *Prog;
> >    
> > -static bool verify_range(struct passwd *pw, struct map_range
> > *range)
> > +static bool verify_range(struct passwd *pw, struct map_range
> > *range,
> > const char **flags) {
> >        /* An empty range is invalid */
> >        if (range->count == 0)
> >            return false;
> >    
> >        /* Test /etc/subgid */
> > -    if (have_sub_gids(pw->pw_name, range->lower, range->count))
> > +    if (have_sub_gids(pw->pw_name, range->lower, range->count,
> > flags))
> >            return true;
> >    
> >        /* Allow a process to map it's own gid */
> > @@ -64,14 +64,14 @@ static bool verify_range(struct passwd *pw,
> > struct
> > map_range *range) }
> >    
> >    static void verify_ranges(struct passwd *pw, int ranges,
> > -    struct map_range *mappings)
> > +               struct map_range *mappings, const char **flags)
> >    {
> >        struct map_range *mapping;
> >        int idx;
> >    
> >        mapping = mappings;
> >        for (idx = 0; idx < ranges; idx++, mapping++) {
> > -        if (!verify_range(pw, mapping)) {
> > +        if (!verify_range(pw, mapping, flags)) {
> >                fprintf(stderr, _( "%s: gid range [%lu-%lu) -> [%lu
> > -%lu) not
> > allowed\n"),                 Prog,
> >                    mapping->upper,
> > @@ -103,6 +103,7 @@ int main(int argc, char **argv)
> >        struct stat st;
> >        struct passwd *pw;
> >        int written;
> > +    const char *flags;
> >    
> >        Prog = Basename (argv[0]);
> >    
> > @@ -177,7 +178,18 @@ int main(int argc, char **argv)
> >        if (!mappings)
> >            usage();
> >    
> > -    verify_ranges(pw, ranges, mappings);
> > +    verify_ranges(pw, ranges, mappings, &flags);
> > +
> > +    if (flags && strlen(flags) != 0) {
> > +        /* only allowed flag is currently deny */
> > +        if (strcmp(flags, "deny") == 0) {
> > +            write_proc(proc_dir_fd, "setgroups", "deny",
> > strlen("deny"));
> > +        } else {
> > +            fprintf(stderr, _("%s: illegal flag in map file:
> > %s\n"),
> > +                Prog, flags);
> > +            exit(EXIT_FAILURE);
> > +        }
> > +    }   
> >    
> >        write_mapping(proc_dir_fd, ranges, mappings, "gid_map");
> >        sub_gid_close();
> 

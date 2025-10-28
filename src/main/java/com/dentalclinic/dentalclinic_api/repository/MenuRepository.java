package com.dentalclinic.dentalclinic_api.repository;

import java.util.List;
import java.util.Set;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.dentalclinic.dentalclinic_api.entity.Menu;
import com.dentalclinic.dentalclinic_api.entity.Role;

@Repository
public interface MenuRepository extends JpaRepository<Menu, Long> {

    // Lấy menu theo roles của user - dùng EntityGraph để load children cùng lúc
    @EntityGraph(attributePaths = {"children"})
    @Query("SELECT DISTINCT m FROM Menu m JOIN m.roles r WHERE r IN :roles AND m.active = true AND m.parent IS NULL ORDER BY m.orderIndex")
    List<Menu> findByRolesInAndParentIsNull(@Param("roles") Set<Role> roles);

    // Lấy TẤT CẢ menu (kể cả submenu) theo roles của user
    @Query("SELECT DISTINCT m FROM Menu m JOIN m.roles r WHERE r IN :roles AND m.active = true ORDER BY m.orderIndex")
    List<Menu> findAllByRolesIn(@Param("roles") Set<Role> roles);

    // Lấy tất cả menu cha (không có parent)
    List<Menu> findByParentIsNullAndActiveTrueOrderByOrderIndex();

    // Lấy menu con theo parent
    List<Menu> findByParentIdAndActiveTrueOrderByOrderIndex(Long parentId);

    // Kiểm tra tên menu đã tồn tại
    boolean existsByName(String name);

    // Lấy tất cả menu với eager loading children và roles (cho admin management)
    @EntityGraph(attributePaths = {"children", "roles"})
    @Query("SELECT m FROM Menu m")
    List<Menu> findAllWithChildrenAndRoles();
}
